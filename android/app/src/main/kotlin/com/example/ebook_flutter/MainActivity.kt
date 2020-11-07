package com.example.ebook_flutter

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import com.example.ebook_flutter.ePubFiles.EpubKittyPlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        EpubKittyPlugin.registerWith(this, flutterEngine);
    }
}
