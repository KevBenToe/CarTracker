import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_service_manager_frontend/core/constants.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({
    required ApiService apiService,
    required SharedPreferences sharedPreferences,
  })  : _apiService = apiService,
        _sharedPreferences = sharedPreferences;

  static const String _demoModeKey = 'demo_mode';

  final ApiService _apiService;
  final SharedPreferences _sharedPreferences;

  bool _isDemoMode = kDemoMode;
  bool _isInitialized = false;
  bool _isCheckingConnectivity = false;

  bool get isDemoMode => _isDemoMode;
  bool get isInitialized => _isInitialized;
  bool get isCheckingConnectivity => _isCheckingConnectivity;

  Future<void> initialize() async {
    _isCheckingConnectivity = true;
    notifyListeners();

    if (kDemoMode) {
      _isDemoMode = true;
    } else {
      final bool reachable = await _apiService.checkConnectivity();
      _isDemoMode = !reachable;
    }

    _isCheckingConnectivity = false;
    _isInitialized = true;
    await _sharedPreferences.setBool(_demoModeKey, _isDemoMode);
    notifyListeners();
  }

  Future<void> refreshConnectivity() async {
    _isCheckingConnectivity = true;
    notifyListeners();

    final bool reachable = await _apiService.checkConnectivity();
    _isDemoMode = kDemoMode ? true : !reachable;

    _isCheckingConnectivity = false;
    await _sharedPreferences.setBool(_demoModeKey, _isDemoMode);
    notifyListeners();
  }
}

