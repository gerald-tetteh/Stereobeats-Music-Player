package com.herokuapp.addodevelop.stereo_beats_main

import android.database.ContentObserver
import io.flutter.plugin.common.EventChannel

class MediaStoreListener(
        val initObserver: (EventChannel.EventSink) -> ContentObserver,
        val cancelObserver: (ContentObserver) -> Unit
) : EventChannel.StreamHandler {

    private var contentObserver: ContentObserver? = null
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        events?.let {
            contentObserver = initObserver(it)
        }
    }

    override fun onCancel(arguments: Any?) {
        contentObserver?.let { cancelObserver(it) }
    }
}