import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:awesome_bubble/awesome_bubble.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String msg = 'Unknown';
  final _bubblePlugin = BubbleService.I;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool inTrip = false;

  bool serviceStarted = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log(state.name, name: 'APP STATE');
    log(inTrip.toString(), name: 'IS SERVICE WORKING?');

    if (!inTrip) return;
    switch (state) {
      case AppLifecycleState.resumed:
        clearNotificationService();
        stopService();
        break;
      case AppLifecycleState.paused:
        startService();
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    clearNotificationService();
    WidgetsBinding.instance.addObserver(this);
    //Request notification permission for android 13 and above
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    //Init The Service, Without init the service you cannot start it
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _bubblePlugin
          .initService(
        screenHeight: MediaQuery.sizeOf(context).height,
      )
          .then((value) {
        serviceStarted = value ?? false;
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void didChangeMetrics() {
    stopService();
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> startService() async {
    bool serviceWorks;
    try {
      final double navigationBar = await getNavHeight();
      if (!mounted) return;
      final double density = MediaQuery.of(context).devicePixelRatio;
      final double screenHeight = MediaQuery.of(context).size.height;
      final double screenWidth = MediaQuery.of(context).size.width * density;
      log(
        {
          'screenWidth-P.P': screenWidth,
          'screenHeight-L.P': screenHeight,
          'density-DPR': density,
          'navigationBarHeight': navigationBar,
        }.toString(),
        name: 'From Flutter Side'.toUpperCase(),
      );
      int randomNum = math.Random().nextInt(500);
      serviceWorks = await _bubblePlugin.startService() ?? false;

      if (!serviceWorks) return;
    } on PlatformException catch (e) {
      serviceWorks = false;
      log(e.message.toString(), name: 'START SERVICE ERROR');
    }
    if (!mounted) return;

    setState(() {
      msg = (serviceWorks
          ? "Success starting chat head service"
          : "Error when starting chat head service");
    });
  }

  Future<void> stopService() async {
    bool serviceStop;
    try {
      serviceStop = await _bubblePlugin.stopService() ?? false;
    } on PlatformException catch (e) {
      log(e.message.toString(), name: 'START SERVICE ERROR');
      serviceStop = false;
    }
    if (!mounted) return;

    setState(() {
      msg = (serviceStop
          ? "Success stop chat head service"
          : "Error when stop hat head service");
    });
  }

  Future<void> clearNotificationService() async =>
      _bubblePlugin.clearNotificationService();

  Future<double> getNavHeight() async {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final screenHeight = MediaQuery.of(context).size.height;

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    final deviceHeight = androidInfo.displayMetrics.heightPx;

    final androidNavHeight = deviceHeight / devicePixelRatio - screenHeight;
    return androidNavHeight;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Bubble Plugin'),
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$msg\n'),
              if (serviceStarted) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!inTrip) {
                      final hasAPermission =
                          await _bubblePlugin.checkPermission();

                      if (!(hasAPermission ?? true)) {
                        await _bubblePlugin.askPermission();
                        return;
                      }
                    }
                    inTrip = !inTrip;

                    log(inTrip.toString(), name: 'bubbleIsWorking');
                    setState(() {});
                  },
                  child: Text(inTrip ? 'Stop trip' : 'Start trip'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class BubbleService {
  BubbleService._();
  static BubbleService I = BubbleService._();

  final AwesomeBubble _bubble = AwesomeBubble.I;

  Future<bool?> initService({
    required double screenHeight,
    String? chatHeadIcon,
    String? notificationIcon,
    String? notificationTitle,
    int? notificationCircleHexColor,
    String? notificationBody,
  }) =>
      _bubble.initService(
        screenHeight: screenHeight,
        chatHeadIcon: chatHeadIcon,
        notificationIcon: notificationIcon,
        notificationTitle: notificationTitle,
        notificationCircleHexColor: notificationCircleHexColor,
        notificationBody: notificationBody,
      );

  Future<bool?> startService({String? notificationTitle}) =>
      _bubble.startService(
        notificationTitle: notificationTitle,
      );

  Future<bool?> stopService() => _bubble.stopService();

  Future<bool?> checkPermission() => _bubble.checkPermission();

  Future<bool?> askPermission() => _bubble.askPermission();

  Future<bool?> clearNotificationService() =>
      _bubble.clearServiceNotification();
}
