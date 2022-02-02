import 'package:flutter/material.dart';
import 'dart:async';

import 'package:watch_connectivity/watch_connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _watch = WatchConnectivity();

  var _count = 0;

  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContexts = <Map<String, dynamic>>[];
  final _log = <String>[];

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _watch.messageStream.listen((e) => _log.add('Received message: $e'));
    _watch.contextStream.listen((e) => _log.add('Received context: $e'));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    _context = await _watch.applicationContext;
    _receivedContexts = await _watch.receivedApplicationContexts;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Paired: $_paired'),
                  Text('Reachable: $_reachable'),
                  Text('Context: $_context'),
                  Text('Received contexts: $_receivedContexts'),
                  TextButton(
                    child: const Text('Refresh'),
                    onPressed: initPlatformState,
                  ),
                  const SizedBox(height: 8),
                  const Text('Send'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text('Message'),
                        onPressed: () {
                          final message = {'data': 'Hello'};
                          _watch.sendMessage(message);
                          setState(() => _log.add('Sent message: $message'));
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('Context'),
                        onPressed: () {
                          _count++;
                          final context = {'data': _count};
                          _watch.updateApplicationContext(context);
                          setState(() => _log.add('Sent context: $context'));
                        },
                      ),
                    ],
                  ),
                  ..._log.reversed.map((e) => Text(e)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
