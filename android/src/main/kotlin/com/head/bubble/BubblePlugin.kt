package com.head.bubble

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Point
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.math.ceil
import kotlin.random.Random


val NOTIFICATION_ID = Random.nextInt(0, 10000);

/** BubblePlugin */
class BubblePlugin: FlutterPlugin, MethodCallHandler,ActivityAware, Activity() {

  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var mActivity: Activity? = null

  private var ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE = 1237

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    println("onAttachedToEngine")

    this.context = flutterPluginBinding.getApplicationContext();
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bubble")
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(@NonNull activityPluginBinding: ActivityPluginBinding) {
    this.mActivity = activityPluginBinding.getActivity();
    println("onAttachedToActivity")
  }


  override fun onDetachedFromActivityForConfigChanges() {
    this.mActivity = null;
    println("onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(@NonNull activityPluginBinding: ActivityPluginBinding) {
    this.mActivity = activityPluginBinding.getActivity();
    println("onReattachedToActivityForConfigChanges")

  }

  override fun onDetachedFromActivity() {
    cancelNotification()
    stopChatHeadService()
    this.mActivity = null;
    println("onDetachedFromActivity")

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    println("onDetachedFromEngine")

  }

  private var density : Float= 0.0f
  private var screenHeightLP : Double?= 0.0
  private var navigationBarHeight : Double= 0.0
  private var screenWidth : Int = 0
  private var chatHeadIcon : String? = ""
  private var notificationIcon : String? = ""
  private var notificationTitle : String? = ""
  private var notificationBody : String? = ""
  private var notificationCircleHexColor : Long? = 0
  private var serviceStarted : Boolean = false

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "initService") {
        stopChatHeadService()
        density = context.resources.displayMetrics.density
        screenHeightLP = call.argument("screenHeight")
        chatHeadIcon = call.argument("chatHeadIcon")
        notificationIcon = call.argument("notificationIcon")
        notificationTitle = call.argument("notificationTitle")
        notificationBody = call.argument("notificationBody")
        notificationCircleHexColor = call.argument("notificationCircleHexColor")
        screenWidth = context.resources.displayMetrics.widthPixels
        if(screenHeightLP == null) return
        navigationBarHeight = ceil(getRealScreenHeight() / density.toDouble() - screenHeightLP!!.toDouble())

        println("[FROM ANDROID NATIVE SIDE]=> screenHeight $screenHeightLP, screenWidth $screenWidth, density $density, navigationBarHeight $navigationBarHeight")
        serviceStarted = true
        result.success(true)
    }
    else if (call.method == "startService") {
      if(!serviceStarted) {
        result.error("INVALID","You MUST initialize the service first :D",null)
        return
      }
      val newNotificationTitle :String? = call.argument("notificationTitle")

      if(checkPermission()) {
        if(newNotificationTitle != null){
          notificationTitle = newNotificationTitle
        }

        navigationBarHeight = ceil(getRealScreenHeight() / density.toDouble() - screenHeightLP!!.toDouble())
        stopChatHeadService()
        if(screenHeightLP == null) return
        startChatHeadService()
        result.success(true)

      } else {
        result.success(false)
      }
    } else if(call.method == "checkPermission"){
      val hasAPermission = checkPermission();
      result.success(hasAPermission)
    } else if(call.method == "askPermission"){
      val askedForPermission = askPermission();
      Toast.makeText(context,"Allow display over other apps permission first",Toast.LENGTH_SHORT).show()
      result.success(askedForPermission)
    } else if(call.method == "stopService"){
      if(!serviceStarted) {
        result.error("INVALID","You MUST initialize the service first :D",null)
        return
      }
      cancelNotification()
      stopChatHeadService()
      result.success(true)
    } else if(call.method == "clearServiceNotification"){
      cancelNotification()
      result.success(true)
    } else {
      result.notImplemented()
    }
  }

  private fun cancelNotification(){
    NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  fun checkPermission(): Boolean {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return Settings.canDrawOverlays(context)
    }
    return false
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  fun askPermission(): Boolean {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (!Settings.canDrawOverlays(context)) {
        val intent = Intent(
          Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
          Uri.parse("package:" + context.packageName)
        )
        if (mActivity == null) {
          intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
          context.startActivity(intent)
          Toast.makeText(
            context,
            "Please grant, Can Draw Over Other Apps permission.",
            Toast.LENGTH_SHORT
          ).show()
        } else {
          mActivity!!.startActivityForResult(intent, ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE)
        }
      } else {
        return true
      }
    }
    return false
  }

  private fun stopChatHeadService() {
    val i = Intent(mActivity!!.applicationContext, ChatHeadService::class.java)
    context.stopService(i)
  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  private fun startChatHeadService(){
    val i = Intent(context, ChatHeadService::class.java)
    i.putExtra("height",getRealScreenHeight())
    i.putExtra("width",screenWidth.toDouble())
    i.putExtra("density",density.toDouble())
    i.putExtra("navigationBarHeight",navigationBarHeight)
    i.putExtra("chatHeadIcon",chatHeadIcon)
    i.putExtra("notificationIcon",notificationIcon)
    i.putExtra("notificationTitle",notificationTitle)
    i.putExtra("notificationBody",notificationBody)
    i.putExtra("notificationCircleHexColor",notificationCircleHexColor)
    i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    i.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
    context.startService(i)
  }

  @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
  private fun getRealScreenHeight() : Double {
    val windowManager = context.getSystemService(WINDOW_SERVICE) as WindowManager
    val display = windowManager.defaultDisplay
    val screenResolution = Point()

    display.getRealSize(screenResolution)

    return screenResolution.y.toDouble()
  }

}