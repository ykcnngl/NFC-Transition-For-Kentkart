package com.example.nfc;

import android.content.Intent;
import android.nfc.cardemulation.HostApduService;
import android.os.Bundle;
import android.util.Log;

public class MyHceService extends HostApduService {

    private static final String TAG = "MyHceService";
    private static final byte[] SUCCESS_STATUS_WORD = {(byte) 0x90, (byte) 0x00};
    private static final byte[] FAILURE_STATUS_WORD = {(byte) 0x6F, (byte) 0x00};

    @Override
    public byte[] processCommandApdu(byte[] commandApdu, Bundle extras) {
        Log.i(TAG, "Okuyucudan (Turnike) APDU komutu geldi: " + bytesToHex(commandApdu));

        // 1. SELECT AID komutunu kontrol et
        if (isSelectAidApdu(commandApdu)) {
            Log.i(TAG, "AID Seçildi, bağlantı kuruldu. Flutter'a haber veriliyor...");

            // BROADCAST YAYINI
            Intent intent = new Intent("NFC_TRANSACTION_SUCCESS");
            intent.setPackage(getPackageName());
            sendBroadcast(intent);

            // 2. Okuyucuya işlemin başarılı olduğunu bildiren yanıt
            byte[] responseData = "IZMIRIM-SUCCESS".getBytes();
            byte[] finalResponse = new byte[responseData.length + SUCCESS_STATUS_WORD.length];
            System.arraycopy(responseData, 0, finalResponse, 0, responseData.length);
            System.arraycopy(SUCCESS_STATUS_WORD, 0, finalResponse, responseData.length, SUCCESS_STATUS_WORD.length);

            return finalResponse;
        }

        return SUCCESS_STATUS_WORD;
    }

    @Override
    public void onDeactivated(int reason) {
        Log.i(TAG, "NFC bağlantısı koptu veya işlem bitti. Sebep: " + reason);
    }

    private boolean isSelectAidApdu(byte[] apdu) {
        return apdu.length >= 2 && apdu[0] == (byte) 0x00 && apdu[1] == (byte) 0xA4;
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X ", b));
        }
        return sb.toString();
    }
}