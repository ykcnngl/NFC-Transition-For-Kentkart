package com.example.nfc;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    // KANAL ADI FLUTTER İLE AYNI YAPILDI
    private static final String CHANNEL = "com.example.nfc/channel";
    private MethodChannel methodChannel;

    private final BroadcastReceiver nfcReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if ("NFC_TRANSACTION_SUCCESS".equals(intent.getAction())) {
                if (methodChannel != null) {
                    methodChannel.invokeMethod("transaction_success", null);
                }
            }
        }
    };

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        IntentFilter filter = new IntentFilter("NFC_TRANSACTION_SUCCESS");

        // Android 14 çökmelerini engelleyen resmi AndroidX çözümü
        ContextCompat.registerReceiver(
                this,
                nfcReceiver,
                filter,
                ContextCompat.RECEIVER_NOT_EXPORTED
        );
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        try {
            unregisterReceiver(nfcReceiver);
        } catch (IllegalArgumentException e) {
            // Güvenlik önlemi
        }
    }
}