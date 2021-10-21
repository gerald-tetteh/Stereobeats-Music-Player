package com.herokuapp.addodevelop.stereo_beats_main;

/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * */

/*
* This file contains methods written in java to perform functions
* that can not by done with dart alone (Accessing native features)
* The methods here are called through the method channel.
* */

import android.Manifest;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.nabinbhandari.android.permissions.PermissionHandler;
import com.nabinbhandari.android.permissions.Permissions;

import org.cmc.music.metadata.MusicMetadata;
import org.cmc.music.metadata.MusicMetadataSet;
import org.cmc.music.myid3.MyID3;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
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
                    switch (call.method) {
                        case "getDeviceAudio": {
                            // checks for permissions
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
                            break;
                        }
                        case "deleteFile": {
                            String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
                            Permissions.check(MainActivity.this, permissions, null, null, new PermissionHandler() {
                                @Override
                                public void onGranted() {
                                    String path = call.argument("path");
                                    deleteFile(result,path);
                                }

                                @Override
                                public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                                    result.error("1", "Permission denied", null);
                                }
                            });
                            break;
                        }
//                        case "getAllAlbumArt": {
//                            String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
//                            Permissions.check(MainActivity.this, permissions, null, null, new PermissionHandler() {
//                                @Override
//                                public void onGranted() {
//                                    getAllAlbumArt(result);
//                                }
//
//                                @Override
//                                public void onDenied(Context context, ArrayList<String> deniedPermissions) {
//                                    result.error("1", "Permission denied", null);
//                                }
//                            });
//                            break;
//                        }
                        case "shareFile": {
                            String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
                            Permissions.check(MainActivity.this, permissions, null, null, new PermissionHandler() {
                                @Override
                                public void onGranted() {
                                    List<String> paths = call.argument("paths");
                                    assert paths != null;
                                    shareFile(result,paths);
                                }

                                @Override
                                public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                                    result.error("1", "Permission denied", null);
                                }
                            });
                            break;
                        }
                        case "updateSong": {
                            String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
                            Permissions.check(MainActivity.this, permissions, null, null, new PermissionHandler() {
                                @Override
                                public void onGranted() {
                                    Map<String,String> songDetails = call.argument("songDetails");
                                    assert songDetails != null;
                                    updateSongItem(result,songDetails);
                                }

                                @Override
                                public void onDenied(Context context, ArrayList<String> deniedPermissions) {
                                    result.error("1", "Permission denied", null);
                                }
                            });
                            break;
                        }
                        default:
                            result.error("error", "error", "error");
                            break;
                    }
                }
        );
    }

    /*
    * This method returns all audio files classified as music.
    * It uses the cursor to search through the media store for all
    * the music on the device.
    * The metadata for each song is also collected and stored
    * in a HasMap.
    * */
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
                MediaStore.Audio.Media._ID,
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
                    metaData.put("songId",c.getString(10));
                    Uri sArtworkUri = Uri
                            .parse("content://media/external/audio/albumart");
                    Uri albumArtUri = ContentUris.withAppendedId(sArtworkUri, Long.parseLong(c.getString(5)));
                    Bitmap bitmap;
                    try {
                        bitmap = MediaStore.Images.Media.getBitmap(MainActivity.this.getContentResolver(), albumArtUri);
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
                        byte[] byteArray = stream.toByteArray();
                        stream.close();
                        bitmap.recycle();
                        metaData.put("artPath2",byteArray);
                    } catch (IOException exception) {
                        metaData.put("artPath2",null);
                    }
                songData.add(metaData);
            }
            c.close();
        }
        result.success(songData);
    }

    /*
    * This method is used to update the metadata(ID3 tags) of a song.
    * An external package is used to update the files then the media store
    * is refreshed.
    * */
    private void updateSongItem(MethodChannel.Result result, Map<String,String> songDetails) {
        String filePath = songDetails.get("path");
        assert filePath != null;
        File audioFile = new File(filePath);
        MusicMetadataSet audioFileSet;
        try {
            audioFileSet = new MyID3().read(audioFile);
            MusicMetadata metadata = new MusicMetadata(songDetails.get("title"));
            metadata.setSongTitle(songDetails.get("title"));
            metadata.setArtist(songDetails.get("artist"));
            metadata.setAlbum(songDetails.get("album"));
            metadata.setYear(songDetails.get("year"));
            metadata.setProducerArtist(songDetails.get("albumArtist"));
            new MyID3().update(audioFile,audioFileSet,metadata);
            MediaScannerConnection.scanFile(MainActivity.this, new String[]{filePath}, new String[]{"audio/*"},
                    new MediaScannerConnection.MediaScannerConnectionClient() {
                        @Override
                        public void onMediaScannerConnected() {

                        }

                        @Override
                        public void onScanCompleted(String path, Uri uri) {
                        }
                    });
            result.success(1);
        } catch (Exception error) {
            result.success(0);
        }
    }

//    private String getAlbumArtUri(String id) {
//        Uri artUri = Uri.parse("content://media/external/audio/albumart");
//        Uri uri = ContentUris.withAppendedId(artUri,Integer.parseInt(id));
//        ;
//        return path;
//    }
//    private void getAlbumArt(String id, MethodChannel.Result result) {
//        String path = null;
//        Cursor cursor = MainActivity.this.getContentResolver().query(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
//                new String[] {MediaStore.Audio.Albums._ID,MediaStore.Audio.Albums.ALBUM_ART}, MediaStore.Audio.Albums._ID + "= ?",
//                new String[]{id},null);
//        if(cursor != null) {
//            if(cursor.moveToFirst()) {
//                path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART));
//            }
//            cursor.close();
//        }
//        result.success(path);
//    }

    /*
    * This method returns the path to the album art
    * for all the music files on the device if it exits.
    * The paths are stored in a map with the album id the
    * key and the path the value.
    * */
//    private void getAllAlbumArt(MethodChannel.Result result) {
//        HashMap<String,Object> albumArts = new HashMap<>();
//            Cursor cursor = MainActivity.this.getContentResolver().query(MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
//                    new String[] {MediaStore.Audio.Albums._ID,MediaStore.Audio.Albums.ALBUM_ART},null,
//                    null,null);
//            if(cursor != null) {
//                for(cursor.moveToFirst();!cursor.isAfterLast();cursor.moveToNext()) {
//                    albumArts.put(cursor.getString(0),cursor.getString(1));
//                }
//                cursor.close();
//            }
//        result.success(albumArts);
//    }

    /*
    * The method is used to permanently remove an audio file from
    * the device.
    * The media store is refreshed to reflect the changes.
    * */
    private void deleteFile(MethodChannel.Result result, String path) {
        File dir = new File(path);
        String selection = MediaStore.Audio.AudioColumns.DATA + "= ?";
        Uri uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
        if(dir.delete()) {
            try {
                MainActivity.this.getContentResolver().delete(uri,selection,new String[] {path});
                result.success(true);
            } catch (Exception e) {
                result.success(false);
            }
        } else {
            result.success(false);
        }
    }

    /*
    * This method opens a dialog box to enable the user to share
    * an audio file with another device or application.
    * */
    private void shareFile(MethodChannel.Result result,  List<String> paths) {
        if (paths.size() == 1) {
            File file = new File(paths.get(0));
            // file provider created in manifest.
            Uri uri = FileProvider.getUriForFile(MainActivity.this,
                    "com.herokuapp.addodevelop.stereo_beats_main.provider",file);
            Intent share = new Intent(Intent.ACTION_SEND);
            share.setType("audio/*");
            share.putExtra(Intent.EXTRA_STREAM, uri);
            startActivity(Intent.createChooser(share, "Share Sound File"));
        } else {
            Intent intent = new Intent();
            intent.setAction(android.content.Intent.ACTION_SEND_MULTIPLE);
            intent.putExtra(Intent.EXTRA_SUBJECT, "Share Songs");
            intent.setType("*/*");

            ArrayList<Uri> files = new ArrayList<>();

            for(String path : paths) {
                File file = new File(path);
                Uri uri = FileProvider.getUriForFile(
                        MainActivity.this,
                        // file provider created in manifest.
                        "com.herokuapp.addodevelop.stereo_beats_main.provider",
                        file);
                files.add(uri);
            }

            intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files);
            startActivity(Intent.createChooser(intent,"Share Songs"));
        }
        result.success(true);
    }
}

