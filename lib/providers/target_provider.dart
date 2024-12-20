import 'package:flutter/foundation.dart';
import '../models/target.dart';
import '../services/firebase_service.dart';

class TargetProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  Target? _currentTarget;
  bool _isLoading = false;

  TargetProvider(this._firebaseService);

  Target? get currentTarget => _currentTarget;
  bool get isLoading => _isLoading;

  Future<void> loadCurrentTarget() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get the current target (assuming one target per period)
      final targets = await _firebaseService.getTargets();
      if (targets.isNotEmpty) {
        // Get the most recent target
        _currentTarget = targets.reduce((a, b) => 
          a.startDate.isAfter(b.startDate) ? a : b);
      }
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTarget(Target target) async {
    await _firebaseService.createTarget(target);
    await loadCurrentTarget();
  }

  Future<void> updateTarget(String id, Map<String, dynamic> data) async {
    await _firebaseService.updateTarget(id, data);
    await loadCurrentTarget();
  }
} 