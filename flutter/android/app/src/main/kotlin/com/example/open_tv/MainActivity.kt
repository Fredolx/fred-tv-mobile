package dev.fredol.open_tv

import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.app.UiModeManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        const val ACTION_PIP_PLAY_PAUSE = "dev.fredol.open_tv.PIP_PLAY_PAUSE"
    }

    private var pipReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "dev.fredol.open_tv/exoplayer",
            ExoPlayerViewFactory(flutterEngine.dartExecutor.binaryMessenger),
        )
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (ExoPlayerView.active?.dispatchDpad(event) == true) {
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    override fun onStart() {
        super.onStart()
        ExoPlayerView.active?.onHostStart()
    }

    override fun onStop() {
        super.onStop()
        ExoPlayerView.active?.onHostStop()
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        val view = ExoPlayerView.active ?: return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !canUsePip() || !view.shouldEnterPip()) return
        try {
            enterPictureInPictureMode(pipParams(view))
        } catch (e: IllegalStateException) {
            Log.w(ExoPlayerView.DIAG_TAG, "Failed to enter PiP", e)
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        ExoPlayerView.active?.onPipModeChanged(isInPictureInPictureMode)
        if (isInPictureInPictureMode) registerPipReceiver() else unregisterPipReceiver()
    }

    override fun onDestroy() {
        unregisterPipReceiver()
        super.onDestroy()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun pipParams(view: ExoPlayerView): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder().setAspectRatio(view.pipAspectRatio())
        builder.setActions(if (view.isLive) emptyList() else listOf(playPauseAction(view.isPlaying())))
        return builder.build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun playPauseAction(playing: Boolean): RemoteAction {
        val intent = PendingIntent.getBroadcast(
            this,
            0,
            Intent(ACTION_PIP_PLAY_PAUSE).setPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val icon = if (playing) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
        val label = if (playing) "Pause" else "Play"
        return RemoteAction(Icon.createWithResource(this, icon), label, label, intent)
    }

    private fun registerPipReceiver() {
        if (pipReceiver != null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val view = ExoPlayerView.active ?: return
                view.togglePlayPause()
                setPictureInPictureParams(pipParams(view))
            }
        }
        val filter = IntentFilter(ACTION_PIP_PLAY_PAUSE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
        pipReceiver = receiver
    }

    private fun unregisterPipReceiver() {
        pipReceiver?.let { unregisterReceiver(it) }
        pipReceiver = null
    }

    private fun canUsePip(): Boolean =
        packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE) && !isTv()

    private fun isTv(): Boolean =
        (getSystemService(UI_MODE_SERVICE) as UiModeManager).currentModeType ==
            Configuration.UI_MODE_TYPE_TELEVISION ||
            packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
}
