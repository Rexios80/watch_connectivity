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

  bool _paired = false;
  bool _reachable = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _paired = await _watch.isPaired;
    _reachable = await _watch.isReachable;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Paired: $_paired'),
              Text('Reachable: $_reachable'),
              ElevatedButton(
                child: const Text('Check again'),
                onPressed: initPlatformState,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
