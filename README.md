![](https://www.babup.com/do.php?img=27721)
# Awesome Bubble
A Flutter Plugin to show Messenger Bubble, over all other apps.This plugin shows overlay bubble and notification.

## _Supported platforms_
- #### Android
![](https://s01.babup.com/uploads/ezgif-com-gif-maker-1-_c7b83.gif)
## _About_
awesome bubble provides you with the ability to show the messenger bubble quickly and easily .. all you have to do is follow the following steps ..

The plugin relies entirely on appearing on top of all applications, so it works for the Android system only.
Because iOS does not provide this feature.

## _Usage_
1- First, add the package to your application in the `pubspec.yaml` file
```yml
    awesome_bubble: ^updated_version
```

2- Head to the AndroidManifest.xml file to add some permissions that the app will need.
```xml
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

3- You can now use the plugin very quickly, and you can see the [example project](https://github.com/mohamedhaloka/awesome_bubble/tree/main/example) for plugin so that you can discover all the advantages easily.

## _Power of Plugin_

- `initService`
  It must be used at the beginning to be able to use the plugin .. as it needs a set of properties that help it to set up the bubble.

| Parameter | Required | Description                                                                                                                                                                                                                                                                                                                                                                         |
| --- | --- |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| 
| `screenHeight` | true | Need to send logical pixel screen height from MediaQurey                                                                                                                                                                                                                                                                                                                            | 
| `chatHeadIcon` | false | If you need to change the chat head icon you can do it by adding the new icon in drawable folder at `android/app/src/main/res/drawable/` and pass the name of image only without the format of image. <br> <br> When you don't pass a icon the default icon is <a src="https://www.babup.com/do.php?img=28116">android chat head icon</a> placed inside the drawable of the plugin. | 
| `notificationIcon` | false | Same as `chatHeadIcon`   <br> <br> When you don't pass a icon the default icon is <a src="https://www.babup.com/do.php?img=28117">android notification icon</a> placed inside the drawable of the plugin.                                                                                                                                                                           | 
| `notificationTitle` | false | when you close the chat head .. we show a notification that contain title and body .. so when you doen't send any title the default notifcation title is `App Name`                                                                                                                                                                                                                 | 
| `notificationBody` | false | Same as `notificationTitle` except the default notification body is `Your Service is still working`                                                                                                                                                                                                                                                                                 | 
| `notificationCircleHexColor` | false | In android 13 and above the system but the notification icon inside the circle so you can change the circle color by this parameter .. <br> <br> But in android 10 and below this parameter used to change the notification icon                                                                                                                                                    | 

- `checkPermission`
  It is used to check whether an app has permission to appear above all apps.
  This function returns a boolean value ..
  ** `true` means the permission allowed, so you can start the bubble
  ** `false` means the permission not allowed , so you need to use `askPermission` first.

- `askPermission`
  Through your use of this function, you will be automatically directed to the system settings, specifically in the section related to Display over other applications, so that you can give this permission to your application.

- `startService`
  Through this function you can start the service to show the bubble.

| Parameter | Required | Description                                                                                                                                                                                                            |
| --- | --- |------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| 
| `notificationTitle` | false | If you want to change the notification title before starting the service you can do it by passing a new notification title, otherwise if you use a notification title in `initService` the service will use it instead | 
| `notificationBody` | false | Same as `notificationTitle`                                                                                                                                                                                            | 

- `stopService`
  Through this function you can stop the service to close the bubble.

- `clearNotificationService`
  Through this function you can clear bubble notification from status bar.

## _Discussion_
Use the [issue tracker](https://github.com/mohamedhaloka/awesome_bubble/issues) for bug reports and feature requests.
Pull requests are welcome.
