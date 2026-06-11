import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_emitStatus);
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _emitStatus(result);
  }

  void _emitStatus(List<ConnectivityResult> results) {
    // For now, if ANY result is not 'none', we are online.
    // results is a list because modern devices can have multiple connections.
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    final status = hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;
    _statusController.add(status);
    debugPrint("ConnectivityService: Current Status - $status");
  }

  Future<ConnectivityStatus> checkStatus() async {
    final result = await _connectivity.checkConnectivity();
    final hasConnection = result.any((r) => r != ConnectivityResult.none);
    return hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  void dispose() {
    _statusController.close();
  }
}
