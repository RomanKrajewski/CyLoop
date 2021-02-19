package de.berlin.htw.hiking4nerds

import io.flutter.plugins.GeneratedPluginRegistrant

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle

import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri


class MainActivity: FlutterActivity() {
  private val CHANNEL = "app.channel.hikingfornerds.data"

  var sharedData: Uri? = null

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine)

    sharedData = intent?.data

    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler{ call, result ->
      if (call.method!!.contentEquals("getSharedData")){
        result.success(sharedData?.toString() ?: "")
        sharedData = null
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    sharedData = intent?.data
  }
}
