package com.herokuapp.addodevelop.stereo_beats_main

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.Intent
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 *
*/

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "stereo.beats/methods"
    private val MEDIA_CHANGE_CHANNEL = "stereo.beats/media-change"
    private lateinit var methodResult: MethodChannel.Result

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "delete") {
                call.argument<String>("path")?.let {
                    methodResult = result
                    deleteSong(it)
                }
            } else {
                result.notImplemented()
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_CHANGE_CHANNEL)
                .setStreamHandler(MediaStoreListener(::initContentObserver, ::cancelContentObserver))
    }

    private fun deleteSong(path: String): Unit {
        val uri = Uri.parse(path)
        try {
            contentResolver.delete(uri,null,null)
            methodResult.success(true)
        } catch (e: SecurityException) {
            val intentSender = when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                    MediaStore.createDeleteRequest(contentResolver, listOf(uri)).intentSender
                }
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                    val recoveredException = e as? RecoverableSecurityException
                    recoveredException?.userAction?.actionIntent?.intentSender
                }
                else -> null
            }
            startIntentSenderForResult(intentSender,0,null,0,0,0,null)
        }
    }
    private fun initContentObserver(events: EventChannel.EventSink): ContentObserver {
        val contentObserver = object: ContentObserver(null) {
            override fun onChange(selfChange: Boolean) {
                events.success(true)
            }
        }
        contentResolver.registerContentObserver(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                true,
                contentObserver
        )
        return contentObserver
    }
    private fun cancelContentObserver(observer: ContentObserver) {
        contentResolver.unregisterContentObserver(observer)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if(requestCode == 0 && resultCode == Activity.RESULT_OK) {
            methodResult.success(true)
        } else {
            methodResult.success(false)
        }
    }
}