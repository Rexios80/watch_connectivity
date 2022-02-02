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

  var _paired = false;
  var _reachable = false;
  var _context = <String, dynamic>{};
  var _receivedContext = <String, dynamic>{};
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
    _receivedContext = await _watch.receivedApplicationContext;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ListView(
            children: [
              Text('Paired: $_paired'),
              Text('Reachable: $_reachable'),
              Text('Context: $_context'),
              Text('Received context: $_receivedContext'),
              ElevatedButton(
                child: const Text('Refresh'),
                onPressed: initPlatformState,
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
