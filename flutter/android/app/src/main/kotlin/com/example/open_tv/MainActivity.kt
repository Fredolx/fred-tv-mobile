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

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (ExoPlayerView.active?.dispatchDpad(event) == true) {
            return true
        }
        return super.dispatchKeyEvent(event)
    }
}
