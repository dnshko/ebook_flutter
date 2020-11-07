package com.example.ebook_flutter.ePubFiles;

import android.app.Activity;
import android.content.Context;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * EpubKittyPlugin
 */
public class EpubKittyPlugin implements MethodCallHandler {

    private Reader reader;
    private ReaderConfig config;
    static private Activity activity;
    static private Context context;

    /**
     * Plugin registration.
     */
    public static void registerWith(Activity activity, FlutterEngine flutterEngine) {
        context = activity;
        activity = activity;

        final MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "epub_kitty");
        channel.setMethodCallHandler(new EpubKittyPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("setConfig")) {
            Map<String, Object> arguments = (Map<String, Object>) call.arguments;
            String identifier = arguments.get("identifier").toString();
            String themeColor = arguments.get("themeColor").toString();
            String scrollDirection = arguments.get("scrollDirection").toString();
            Boolean allowSharing = Boolean.parseBoolean(arguments.get("allowSharing").toString());
            config = new ReaderConfig(context, identifier, themeColor, scrollDirection, allowSharing);
        } else if (call.method.equals("open")) {
            Map<String, Object> arguments = (Map<String, Object>) call.arguments;
            String bookPath = arguments.get("bookPath").toString();
            reader = new Reader(context, config);
            reader.open(bookPath);
        } else if (call.method.equals("close")) {
            reader.close();
        } else {
            result.notImplemented();
        }
    }
}
