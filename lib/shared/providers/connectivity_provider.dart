import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityNotifier() : super(true) {
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    state = !results.contains(ConnectivityResult.none);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    state = !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
