package dev.fredol.open_tv

import android.app.AlertDialog
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
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
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.ui.AspectRatioFrameLayout
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

    private val methodChannel = MethodChannel(messenger, "dev.fredol.open_tv/exoplayer_$viewId")
    private val handler = Handler(Looper.getMainLooper())
    private val player: ExoPlayer
    private val playerView: PlayerView
    private val root: FrameLayout

    private var zoomed = false
    private var reconnecting = false

    companion object {
        var active: ExoPlayerView? = null
    }

    init {
        methodChannel.setMethodCallHandler(this)

        val headers = HashMap<String, String>()
        (params["referer"] as? String)?.takeIf { it.isNotEmpty() }?.let { headers["Referer"] = it }
        (params["origin"] as? String)?.takeIf { it.isNotEmpty() }?.let { headers["Origin"] = it }
        val userAgent = params["userAgent"] as? String

        val httpFactory = DefaultHttpDataSource.Factory()
            .setAllowCrossProtocolRedirects(true)
            .apply {
                if (headers.isNotEmpty()) setDefaultRequestProperties(headers)
                if (!userAgent.isNullOrEmpty()) setUserAgent(userAgent)
            }

        player = ExoPlayer.Builder(context)
            .setMediaSourceFactory(DefaultMediaSourceFactory(context).setDataSourceFactory(httpFactory))
            .build()

        root = LayoutInflater.from(context)
            .inflate(R.layout.exo_player_container, null) as FrameLayout
        playerView = root.findViewById(R.id.player_view)
        playerView.player = restrictedPlayer(player, isLive)
        playerView.setShowSubtitleButton(true)
        playerView.setShowNextButton(false)
        playerView.setShowPreviousButton(false)
        playerView.controllerShowTimeoutMs = 3000

        val topBar = root.findViewById<View>(R.id.top_bar)
        root.findViewById<TextView>(R.id.title_text).text = title
        root.findViewById<View>(R.id.back_button).setOnClickListener {
            methodChannel.invokeMethod("onBack", null)
        }
        // audio_button / zoom_button now live inside the custom control layout (bottom bar).
        playerView.findViewById<View>(R.id.audio_button).setOnClickListener { showAudioTrackDialog() }
        playerView.findViewById<View>(R.id.zoom_button).setOnClickListener { toggleZoom() }

        // D-pad handling is driven natively via MainActivity.dispatchKeyEvent -> dispatchDpad.
        playerView.isFocusable = true
        active = this

        // Keep the custom top bar in sync with the native controller's show/hide.
        playerView.setControllerVisibilityListener(
            PlayerView.ControllerVisibilityListener { visibility ->
                topBar.visibility = visibility
                if (isLive && visibility == View.VISIBLE) hideLiveControls()
            }
        )
        if (isLive) hideLiveControls()

        player.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                if (isLive) scheduleReconnect()
            }

            override fun onPlaybackStateChanged(state: Int) {
                if (state == Player.STATE_ENDED && isLive) scheduleReconnect()
            }
        })

        player.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
        if (!isLive && startPositionMs > 0) player.seekTo(startPositionMs)
        player.playWhenReady = true
        player.prepare()
    }

    /**
     * Restricts the commands the native controls react to:
     *  - always removes speed control,
     *  - for livestreams also removes seek commands (hides the scrubber) and play/pause
     *    (a livestream shouldn't be pausable — it would just fall behind live).
     */
    private fun restrictedPlayer(delegate: Player, isLive: Boolean): Player {
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
        val blockedSet = blocked.toIntArray()
        return object : ForwardingPlayer(delegate) {
            override fun getAvailableCommands(): Player.Commands {
                val builder = super.getAvailableCommands().buildUpon()
                for (command in blockedSet) builder.remove(command)
                return builder.build()
            }

            override fun isCommandAvailable(command: Int): Boolean =
                command !in blockedSet && super.isCommandAvailable(command)
        }
    }

    /**
     * Hides the controls that don't apply to livestreams (not just disabled): the seekbar,
     * the time labels and the play/pause button (a livestream can't be seeked or paused).
     */
    private fun hideLiveControls() {
        intArrayOf(
            androidx.media3.ui.R.id.exo_progress,
            androidx.media3.ui.R.id.exo_time,
            androidx.media3.ui.R.id.exo_play_pause,
        ).forEach { id -> playerView.findViewById<View?>(id)?.visibility = View.GONE }
    }

    /**
     * Dedicated audio-track selector. Tapping a row applies it and closes immediately
     * (no OK/Cancel), matching Media3's native subtitle popup.
     */
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

        // The app uses a framework (non-AppCompat) theme, so force a platform dialog theme.
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

    /**
     * Handles a remote/D-pad key entirely in native code (called from
     * [MainActivity.dispatchKeyEvent], before Flutter sees the event).
     * Returns true if consumed. Non-navigation keys (e.g. Back) are left for Flutter.
     */
    fun dispatchDpad(event: KeyEvent): Boolean {
        val keyCode = event.keyCode
        if (!isNavOrSelect(keyCode)) return false

        // If controls are hidden or nothing is focused yet, just show them and focus a default.
        if (!playerView.isControllerFullyVisible || root.findFocus() == null) {
            if (event.action == KeyEvent.ACTION_DOWN) {
                playerView.showController()
                focusDefaultControl()
            }
            return true
        }

        val current = root.findFocus()!!
        // Let the focused control handle it first (timebar scrubbing, button activation).
        if (current.dispatchKeyEvent(event)) {
            playerView.showController()
            return true
        }
        // Otherwise move focus in the pressed direction.
        if (event.action == KeyEvent.ACTION_DOWN && isDirection(keyCode)) {
            val direction = directionFor(keyCode)
            current.focusSearch(direction)?.requestFocus(direction)
            playerView.showController()
        }
        return true
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
        handler.postDelayed({
            reconnecting = false
            player.setMediaItem(MediaItem.fromUri(Uri.parse(url)))
            player.playWhenReady = true
            player.prepare()
        }, 1000)
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
