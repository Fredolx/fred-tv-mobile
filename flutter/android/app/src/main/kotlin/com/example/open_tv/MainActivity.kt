package dev.fredol.open_tv

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "dev.fredol.open_tv/exoplayer",
            ExoPlayerViewFactory(flutterEngine.dartExecutor.binaryMessenger),
        )
    }

    // Route remote/D-pad keys to the native ExoPlayer controls before Flutter sees them.
    // When no native player is on screen (or the key isn't navigation), Flutter handles it.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (ExoPlayerView.active?.dispatchDpad(event) == true) {
            return true
        }
        return super.dispatchKeyEvent(event)
    }
}
