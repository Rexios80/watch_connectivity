import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watch_connectivity_garmin/watch_connectivity_garmin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

/// the app
class MyApp extends StatefulWidget {
  /// constructor
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// a late member because we need to use the initialise function for Garmin
  late WatchConnectivityGarmin _watch;

  int _lastSentDataId = 0;
  bool _supported = false;
  bool _paired = false;
  bool _reachable = false;
  final _receivedMessages = <String, dynamic>{};
  final _log = <String>[];

  Timer? timer;

  @override
  void initState() {
    super.initState();

    _initialiseGarminWatch();
  }

  Future<void> _initialiseGarminWatch() async {
    _watch = WatchConnectivityGarmin();

    if (await _watch.isSupported) {
      await _watch.initialize(
        GarminInitializationOptions(
          //TODO replace with your own application id and URL scheme
          applicationId: 'TODO_APPLICATION_ID_FROM_GARMIN_APP_HERE',
          // same package name as in the Info.plist 'CFBundleURLSchemes'
          urlScheme: 'dev.rexios.watch_connectivity_garmin',
          autoUI: true,
        ),
      );

      _watch.messageStream.listen((e) {
        setState(() {
          _log.add('Received message: $e');
          _receivedMessages.addAll(e);
        });
      }).onError(
        (error) => setState(() => _log.add('Cannot receive message: $error')),
      );
    }
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    _supported = await _watch.isSupported;
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _initialiseGarminWatch,
                    child: const Text('Initialise'),
                  ),
                  Text('Supported: $_supported'),
                  Text('Paired: $_paired'),
                  Text('Reachable: $_reachable'),
                  Text('Received messages: $_receivedMessages'),
                  TextButton(
                    onPressed: initPlatformState,
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: sendMessage,
                    child: const Text('Send Message'),
                  ),
                  TextButton(
                    onPressed: toggleBackgroundMessaging,
                    child: Text(
                      '${timer == null ? 'Start' : 'Stop'} background messaging',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Log'),
                  ..._log.reversed.map(Text.new),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void sendMessage() {
    final messageMap = {
      'id': ++_lastSentDataId,
      'content': 'Hello from the phone!',
    };
    _watch.sendMessage(messageMap);
    setState(() => _log.add('Sent message: $messageMap'));
  }

  void toggleBackgroundMessaging() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => sendMessage());
    } else {
      timer?.cancel();
      timer = null;
    }
    setState(() {});
  }
}
