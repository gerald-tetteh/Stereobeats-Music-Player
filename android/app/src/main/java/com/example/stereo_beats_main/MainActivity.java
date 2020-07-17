package com.example.stereo_beats_main;

import android.Manifest;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import com.nabinbhandari.android.permissions.PermissionHandler;
import com.nabinbhandari.android.permissions.Permissions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(),"stereo.beats/metadata").setMethodCallHandler(
                (call, result) -> {
                    if(call.method.equals("getDeviceAudio")) {
                        String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
                        Permissions.check(MainActivity.this, permissions, null, null, new PermissionHandler() {
                            @Override
                            public void onGranted() {
                                getDeviceAudio(result);
                            }

                            @Override
                            public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                                result.error("1", "Permission denied", null);
                            }
                        });
                    } else if(call.method.equals("getAlbumArt")) {
                        String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
                        Permissions.check(MainActivity.this, permissions, null, null, new PermissionHandler() {
                            @Override
                            public void onGranted() {
                                String id = call.argument("id");
                                getAlbumArt(id,result);
                            }

                            @Override
                            public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                                result.error("1", "Permission denied", null);
                            }
                        });
                    } else {
                        result.error("error","error","error");
                    }
                }
        );

//        new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(),"stereo.beats/albumArt").setMethodCallHandler(
//                (call, result) -> {
//                    if(call.method.equals("getAlbumArt")){
//                        String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
//                        Permissions.check(getApplicationContext(), permissions, null, null, new PermissionHandler() {
//                            @Override
//                            public void onGranted() {
//                                getAlbumArt(result);
//                            }
//
//                            @Override
//                            public void onDenied(Context context, ArrayList<String> deniedPermissions) {
//                                result.error("1", "Permission denied", null);
//                            }
//                        });
//                    } else {
//                        result.error("error","error","error");
//                    }
//                }
//        );
    }

    private void getDeviceAudio(MethodChannel.Result result) {

        List<Map<String,Object>> songData = new ArrayList<>();
        Uri uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
        String[] projection = {
                MediaStore.Audio.AudioColumns.IS_MUSIC,
                MediaStore.Audio.AudioColumns.DATA,
                MediaStore.Audio.AudioColumns.TITLE,
                MediaStore.Audio.AudioColumns.ALBUM,
                MediaStore.Audio.ArtistColumns.ARTIST,
                MediaStore.Audio.AlbumColumns.ALBUM_ID,
                MediaStore.Audio.AudioColumns.DATE_ADDED,
                MediaStore.Audio.AudioColumns.DURATION,
                MediaStore.Audio.AlbumColumns.ARTIST,
                MediaStore.Audio.AudioColumns.YEAR,
        };
        Cursor c = MainActivity.this.getContentResolver().query(uri, projection, MediaStore.Audio.AudioColumns.IS_MUSIC + " > ?", new String[]{"0"},
                MediaStore.Audio.AudioColumns.TITLE + " ASC");


        if(c != null) {
            while (c.moveToNext()) {
                    Map<String,Object> metaData = new HashMap<>();
                    metaData.put("path",c.getString(1));
                    metaData.put("title",c.getString(2));
                    metaData.put("album",c.getString(3));
                    metaData.put("artist",c.getString(4));
                    metaData.put("albumId",c.getString(5));
                    metaData.put("dateAdded",c.getString(6));
                    metaData.put("duration",c.getString(7));
                    metaData.put("albumArtist",c.getString(8));
                    metaData.put("year",c.getString(9));
                    songData.add(metaData);
            }
            c.close();
        }
        result.success(songData);
    }

//    private String getAlbumArtUri(String id) {
//        Uri artUri = Uri.parse("content://media/external/audio/albumart");
//        Uri uri = ContentUris.withAppendedId(artUri,Integer.parseInt(id));
//        ;
//        return path;
//    }
    private void getAlbumArt(String id, MethodChannel.Result result) {
        String path = null;
        Cursor cursor = MainActivity.this.getContentResolver().query(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                new String[] {MediaStore.Audio.Albums._ID,MediaStore.Audio.Albums.ALBUM_ART}, MediaStore.Audio.Albums._ID + "= ?",
                new String[]{id},null);
        if(cursor != null) {
            if(cursor.moveToFirst()) {
                path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART));
            }
            cursor.close();
        }
        result.success(path);
    }
}

