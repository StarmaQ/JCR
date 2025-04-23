import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show ValueNotifier;

class LabelService {
  // Singleton
  static final LabelService _instance = LabelService._internal();
  factory LabelService() => _instance;
  LabelService._internal();

  Timer? _timer;
  String _lastLabel = '';
  // Notifier for UI listeners
  final ValueNotifier<String?> labelNotifier = ValueNotifier(null);

  /// Start random notifications every [interval]
  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    _timer = Timer.periodic(interval, (_) => _simulate());
  }

  void _simulate() {
    final isCorrect = Random().nextBool();
    final message = isCorrect
        ? 'You recycled correctly'
        : 'You recycled incorrectly';
    labelNotifier.value = message;
  }

  /// Stop polling and dispose notifier
  void dispose() {
    _timer?.cancel();
    labelNotifier.dispose();
  }
} 