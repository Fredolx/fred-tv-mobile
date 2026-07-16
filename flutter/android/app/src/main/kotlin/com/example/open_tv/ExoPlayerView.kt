package dev.fredol.open_tv

import android.app.AlertDialog
import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.media3.common.C
import androidx.media3.common.Format
import androidx.media3.common.ForwardingPlayer
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.LoadControl
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.upstream.DefaultLoadErrorHandlingPolicy
import androidx.media3.exoplayer.util.EventLogger
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.DefaultTimeBar
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.Locale

class ExoPlayerView(
    context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    params: Map<String, Any?>,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val isLive = params["isLive"] as? Boolean ?: false
    private val url = params["url"] as String
    private val startPositionMs = (params["startPositionMs"] as? Number)?.toLong() ?: 0L
    private val title = params["title"] as? String ?: ""
    private val debug = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    private val methodChannel = MethodChannel(messenger, "dev.fredol.open_tv/exoplayer_$viewId")
    private val handler = Handler(Looper.getMainLooper())
    private val player: ExoPlayer
    private val playerView: PlayerView
    private val root: FrameLayout

    private var zoomed = false
    private var reconnecting = false
    private var reconnectAttempts = 0

    companion object {
        var active: ExoPlayerView? = null
        const val DIAG_TAG = "ExoPlayerDiag"
        const val SEEK_INCREMENT_MS = 10_000L
        val RECONNECT_DELAYS_MS = longArrayOf(1_000L, 3_000L, 5_000L)
        const val BUFFER_MIN_MS = 30_000
        const val BUFFER_MAX_MS = 60_000
        const val BUFFER_FOR_PLAYBACK_MS = 10_000
        const val BUFFER_RESUME_AFTER_REBUFFER_MS = 10_000
        const val HTTP_CONNECT_TIMEOUT_MS = 15_000
        const val HTTP_READ_TIMEOUT_MS = 60_000
    }

    init {
        methodChannel.setMethodCallHandler(this)
        player = ExoPlayer.Builder(context)
            .setMediaSourceFactory(
                DefaultMediaSourceFactory(context)
                    .setDataSourceFactory(createHttpFactory(params))
                    .setLoadErrorHandlingPolicy(DefaultLoadErrorHandlingPolicy(999))
            )
            .setLoadControl(tolerantLoadControl())
            .setSeekBackIncrementMs(SEEK_INCREMENT_MS)
            .setSeekForwardIncrementMs(SEEK_INCREMENT_MS)
            .build()
        root = LayoutInflater.from(context)
            .inflate(R.layout.exo_player_container, null) as FrameLayout
        playerView = root.findViewById(R.id.player_view)
        if (debug) player.addAnalyticsListener(EventLogger(DIAG_TAG))
        attachPlayer()
        bindControls()
        observeForReconnect()
        active = this
        startPlayback()
    }

    private fun createHttpFactory(params: Map<String, Any?>): DefaultHttpDataSource.Factory {
        val headers = HashMap<String, String>()
        (params["referer"] as? String)?.takeIf { it.isNotEmpty() }?.let { headers["Referer"] = it }
        (params["origin"] as? String)?.takeIf { it.isNotEmpty() }?.let { headers["Origin"] = it }
        val userAgent = params["userAgent"] as? String
        return DefaultHttpDataSource.Factory()
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(HTTP_CONNECT_TIMEOUT_MS)
            .setReadTimeoutMs(HTTP_READ_TIMEOUT_MS)
            .apply {
                if (headers.isNotEmpty()) setDefaultRequestProperties(headers)
                if (!userAgent.isNullOrEmpty()) setUserAgent(userAgent)
            }
    }

    private fun attachPlayer() {
        playerView.player = restrictedPlayer(player, isLive)
        playerView.setShowSubtitleButton(true)
        playerView.setShowNextButton(false)
        playerView.setShowPreviousButton(false)
        playerView.setShowBuffering(PlayerView.SHOW_BUFFERING_ALWAYS)
        playerView.controllerShowTimeoutMs = 1500
        playerView.isFocusable = true
        makeSeekBarGranular()
        syncControllerVisibility()
        if (isLive) hideLiveControls()
    }

    private fun makeSeekBarGranular() {
        val timeBar = playerView.findViewById<View?>(androidx.media3.ui.R.id.exo_progress) as? DefaultTimeBar
        timeBar?.setKeyTimeIncrement(SEEK_INCREMENT_MS)
    }

    private fun syncControllerVisibility() {
        val topBar = playerView.findViewById<View>(R.id.top_bar)
        playerView.setControllerVisibilityListener(
            PlayerView.ControllerVisibilityListener { visibility ->
                topBar.visibility = visibility
                if (isLive && visibility == View.VISIBLE) hideLiveControls()
            }
        )
    }

    private fun bindControls() {
        playerView.findViewById<TextView>(R.id.title_text).text = title
        playerView.findViewById<View>(R.id.back_button).setOnClickListener {
            methodChannel.invokeMethod("onBack", null)
        }
        playerView.findViewById<View>(R.id.audio_button).setOnClickListener { showAudioTrackDialog() }
        playerView.findViewById<View>(R.id.zoom_button).setOnClickListener { toggleZoom() }
    }

    private fun tolerantLoadControl(): LoadControl =
        DefaultLoadControl.Builder()
            .setBufferDurationsMs(
                BUFFER_MIN_MS,
                BUFFER_MAX_MS,
                BUFFER_FOR_PLAYBACK_MS,
                BUFFER_RESUME_AFTER_REBUFFER_MS,
            )
            .build()

    private fun observeForReconnect() {
        player.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                if (debug) Log.e(DIAG_TAG, "onPlayerError code=${error.errorCodeName} cause=${error.cause}", error)
                if (isLive) scheduleReconnect()
            }

            override fun onPlaybackStateChanged(state: Int) {
                if (debug) Log.i(DIAG_TAG, "onPlaybackStateChanged state=${stateName(state)}")
                when (state) {
                    Player.STATE_READY -> reconnectAttempts = 0
                    Player.STATE_ENDED -> if (isLive) scheduleReconnect()
                }
            }
        })
    }

    private fun stateName(state: Int): String = when (state) {
        Player.STATE_IDLE -> "IDLE"
        Player.STATE_BUFFERING -> "BUFFERING"
        Player.STATE_READY -> "READY"
        Player.STATE_ENDED -> "ENDED"
        else -> "UNKNOWN($state)"
    }

    private fun startPlayback() {
        player.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
        if (!isLive && startPositionMs > 0) player.seekTo(startPositionMs)
        player.playWhenReady = true
        player.prepare()
    }

    private fun restrictedPlayer(delegate: Player, isLive: Boolean): Player {
        val blocked = blockedCommands(isLive)
        return object : ForwardingPlayer(delegate) {
            override fun getAvailableCommands(): Player.Commands {
                val builder = super.getAvailableCommands().buildUpon()
                for (command in blocked) builder.remove(command)
                return builder.build()
            }

            override fun isCommandAvailable(command: Int): Boolean =
                command !in blocked && super.isCommandAvailable(command)
        }
    }

    private fun blockedCommands(isLive: Boolean): IntArray {
        val blocked = mutableListOf(Player.COMMAND_SET_SPEED_AND_PITCH)
        if (isLive) {
            blocked += listOf(
                Player.COMMAND_PLAY_PAUSE,
                Player.COMMAND_SEEK_BACK,
                Player.COMMAND_SEEK_FORWARD,
                Player.COMMAND_SEEK_IN_CURRENT_MEDIA_ITEM,
                Player.COMMAND_SEEK_TO_PREVIOUS,
                Player.COMMAND_SEEK_TO_NEXT,
                Player.COMMAND_SEEK_TO_PREVIOUS_MEDIA_ITEM,
                Player.COMMAND_SEEK_TO_NEXT_MEDIA_ITEM,
            )
        }
        return blocked.toIntArray()
    }

    private fun hideLiveControls() {
        intArrayOf(
            androidx.media3.ui.R.id.exo_progress,
            androidx.media3.ui.R.id.exo_time,
            androidx.media3.ui.R.id.exo_play_pause,
            androidx.media3.ui.R.id.exo_rew_with_amount,
            androidx.media3.ui.R.id.exo_ffwd_with_amount,
        ).forEach { id -> playerView.findViewById<View?>(id)?.visibility = View.GONE }
    }

    private fun showAudioTrackDialog() {
        val activePlayer = playerView.player ?: return
        val groups = activePlayer.currentTracks.groups.filter { it.type == C.TRACK_TYPE_AUDIO }
        if (groups.isEmpty()) return

        val labels = mutableListOf("Auto")
        val overrides = mutableListOf<TrackSelectionOverride?>(null)
        for (group in groups) {
            for (i in 0 until group.length) {
                if (!group.isTrackSupported(i)) continue
                val prefix = if (group.isTrackSelected(i)) "✓ " else ""
                labels.add(prefix + audioTrackLabel(group.getTrackFormat(i), overrides.size))
                overrides.add(TrackSelectionOverride(group.mediaTrackGroup, i))
            }
        }

        AlertDialog.Builder(playerView.context, android.R.style.Theme_DeviceDefault_Dialog_Alert)
            .setTitle(R.string.exo_audio)
            .setItems(labels.toTypedArray()) { dialog, which ->
                val params = activePlayer.trackSelectionParameters.buildUpon()
                    .clearOverridesOfType(C.TRACK_TYPE_AUDIO)
                    .setTrackTypeDisabled(C.TRACK_TYPE_AUDIO, false)
                overrides[which]?.let { params.addOverride(it) }
                activePlayer.trackSelectionParameters = params.build()
                dialog.dismiss()
            }
            .show()
    }

    private fun audioTrackLabel(format: Format, fallbackIndex: Int): String {
        format.label?.let { return it }
        val lang = format.language
        if (!lang.isNullOrEmpty() && lang != "und") {
            val display = Locale(lang).displayLanguage
            return if (display.isNotEmpty()) display else lang
        }
        return when (format.channelCount) {
            1 -> "Mono"
            2 -> "Stereo"
            6 -> "5.1"
            8 -> "7.1"
            Format.NO_VALUE -> "Audio $fallbackIndex"
            else -> "${format.channelCount} channels"
        }
    }

    private fun toggleZoom() {
        zoomed = !zoomed
        playerView.resizeMode = if (zoomed) {
            AspectRatioFrameLayout.RESIZE_MODE_ZOOM
        } else {
            AspectRatioFrameLayout.RESIZE_MODE_FIT
        }
    }

    fun dispatchDpad(event: KeyEvent): Boolean {
        val keyCode = event.keyCode
        if (!isNavOrSelect(keyCode)) return false

        if (controlsNeedWaking()) {
            if (event.action == KeyEvent.ACTION_DOWN) wakeControls()
            return true
        }

        val focused = root.findFocus()!!
        if (focused.dispatchKeyEvent(event)) {
            playerView.showController()
            return true
        }
        if (event.action == KeyEvent.ACTION_DOWN && isDirection(keyCode)) {
            moveFocus(focused, keyCode)
        }
        return true
    }

    private fun controlsNeedWaking(): Boolean =
        !playerView.isControllerFullyVisible || root.findFocus() == null

    private fun wakeControls() {
        playerView.showController()
        focusDefaultControl()
    }

    private fun moveFocus(from: View, keyCode: Int) {
        val direction = directionFor(keyCode)
        from.focusSearch(direction)?.requestFocus(direction)
        playerView.showController()
    }

    private fun focusDefaultControl() {
        val candidates = listOfNotNull(
            playerView.findViewById<View?>(androidx.media3.ui.R.id.exo_play_pause),
            playerView.findViewById<View?>(R.id.audio_button),
            playerView.findViewById<View?>(R.id.zoom_button),
        )
        candidates.firstOrNull { it.isShown }?.requestFocus()
    }

    private fun isNavOrSelect(keyCode: Int): Boolean =
        isDirection(keyCode) ||
            keyCode == KeyEvent.KEYCODE_DPAD_CENTER ||
            keyCode == KeyEvent.KEYCODE_ENTER ||
            keyCode == KeyEvent.KEYCODE_NUMPAD_ENTER

    private fun isDirection(keyCode: Int): Boolean =
        keyCode == KeyEvent.KEYCODE_DPAD_UP ||
            keyCode == KeyEvent.KEYCODE_DPAD_DOWN ||
            keyCode == KeyEvent.KEYCODE_DPAD_LEFT ||
            keyCode == KeyEvent.KEYCODE_DPAD_RIGHT

    private fun directionFor(keyCode: Int): Int = when (keyCode) {
        KeyEvent.KEYCODE_DPAD_UP -> View.FOCUS_UP
        KeyEvent.KEYCODE_DPAD_DOWN -> View.FOCUS_DOWN
        KeyEvent.KEYCODE_DPAD_LEFT -> View.FOCUS_LEFT
        else -> View.FOCUS_RIGHT
    }

    private fun scheduleReconnect() {
        if (reconnecting) return
        reconnecting = true
        val delay = RECONNECT_DELAYS_MS[reconnectAttempts.coerceAtMost(RECONNECT_DELAYS_MS.lastIndex)]
        if (debug) Log.w(DIAG_TAG, "scheduleReconnect attempt=$reconnectAttempts delayMs=$delay")
        reconnectAttempts++
        handler.postDelayed({
            reconnecting = false
            player.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
            player.playWhenReady = true
            player.prepare()
        }, delay)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPosition" -> result.success(player.currentPosition)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = root

    override fun dispose() {
        if (active === this) active = null
        methodChannel.setMethodCallHandler(null)
        handler.removeCallbacksAndMessages(null)
        playerView.player = null
        player.release()
    }
}
