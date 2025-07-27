import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:enms/models/network_model.dart';
import 'package:enms/models/app_model.dart';
import 'package:enms/models/speed_limit_model.dart';
import 'package:enms/models/data_usage.dart';

class DataProvider with ChangeNotifier {
  List<NetworkModel> _networks = [];
  List<AppModel> _apps = [];
  List<SpeedLimitModel> _speedLimits = [];
  String _selectedTimeRange = 'daily';
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _customEndDate = DateTime.now();

  List<NetworkModel> get networks => _networks;
  List<AppModel> get apps => _apps;
  List<SpeedLimitModel> get speedLimits => _speedLimits;
  String get selectedTimeRange => _selectedTimeRange;
  DateTime get customStartDate => _customStartDate;
  DateTime get customEndDate => _customEndDate;

  DataProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadData();
    if (_networks.isEmpty || _apps.isEmpty) {
      await _generateSampleData();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final networksJson = prefs.getString('networks');
    if (networksJson != null) {
      final List<dynamic> networksList = json.decode(networksJson);
      _networks = networksList.map((e) => NetworkModel.fromJson(e)).toList();
    }

    final appsJson = prefs.getString('apps');
    if (appsJson != null) {
      final List<dynamic> appsList = json.decode(appsJson);
      _apps = appsList.map((e) => AppModel.fromJson(e)).toList();
    }

    final speedLimitsJson = prefs.getString('speedLimits');
    if (speedLimitsJson != null) {
      final List<dynamic> speedLimitsList = json.decode(speedLimitsJson);
      _speedLimits = speedLimitsList.map((e) => SpeedLimitModel.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('networks', json.encode(_networks.map((e) => e.toJson()).toList()));
    await prefs.setString('apps', json.encode(_apps.map((e) => e.toJson()).toList()));
    await prefs.setString('speedLimits', json.encode(_speedLimits.map((e) => e.toJson()).toList()));
  }

  Future<void> _generateSampleData() async {
    _networks = [
      _createSampleNetwork('1', 'شبكة المنزل', 'HomeWiFi', true, 85, 'WPA2'),
      _createSampleNetwork('2', 'شبكة العمل', 'OfficeNet', false, 65, 'WPA3'),
      _createSampleNetwork('3', 'شبكة الضيوف', 'GuestNetwork', false, 45, 'WPA2'),
      _createSampleNetwork('4', 'الشبكة المحمولة', 'MobileHotspot', false, 70, 'WPA2'),
    ];

    _apps = [
      _createSampleApp('1', 'واتساب', 'com.whatsapp', '📱', false),
      _createSampleApp('2', 'يوتيوب', 'com.google.android.youtube', '📺', false),
      _createSampleApp('3', 'فيسبوك', 'com.facebook.katana', '👥', false),
      _createSampleApp('4', 'إنستغرام', 'com.instagram.android', '📸', false),
      _createSampleApp('5', 'تيك توك', 'com.zhiliaoapp.musically', '🎵', false),
      _createSampleApp('6', 'تويتر', 'com.twitter.android', '🐦', false),
      _createSampleApp('7', 'نتفليكس', 'com.netflix.mediaclient', '🎬', false),
      _createSampleApp('8', 'سبوتيفاي', 'com.spotify.music', '🎶', false),
      _createSampleApp('9', 'تليجرام', 'org.telegram.messenger', '✈️', false),
      _createSampleApp('10', 'جوجل كروم', 'com.android.chrome', '🌐', false),
    ];

    await _saveData();
    notifyListeners();
  }

  NetworkModel _createSampleNetwork(String id, String name, String ssid,
      bool isConnected, int signalStrength, String securityType) {
    Map<String, DataUsage> generateUsageData(int days) {
      final now = DateTime.now();
      final random = Random();
      Map<String, DataUsage> usage = {};
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final key = date.toIso8601String().split('T')[0];
        usage[key] = DataUsage(
          downloadMB: random.nextDouble() * 1000 + 100,
          uploadMB: random.nextDouble() * 200 + 50,
          timestamp: date,
        );
      }
      return usage;
    }

    return NetworkModel(
      id: id,
      name: name,
      ssid: ssid,
      isConnected: isConnected,
      signalStrength: signalStrength,
      securityType: securityType,
      dailyUsage: generateUsageData(30),
      weeklyUsage: generateUsageData(12),
      monthlyUsage: generateUsageData(6),
    );
  }

  AppModel _createSampleApp(String id, String name, String packageName,
      String icon, bool isSystemApp) {
    Map<String, DataUsage> generateUsageData(int days) {
      final now = DateTime.now();
      final random = Random();
      Map<String, DataUsage> usage = {};
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final key = date.toIso8601String().split('T')[0];
        usage[key] = DataUsage(
          downloadMB: random.nextDouble() * 500 + 10,
          uploadMB: random.nextDouble() * 100 + 5,
          timestamp: date,
        );
      }
      return usage;
    }

    Map<String, Map<String, DataUsage>> generateNetworkUsage() {
      Map<String, Map<String, DataUsage>> networkUsage = {};
      for (final network in _networks) {
        networkUsage[network.id] = generateUsageData(30);
      }
      return networkUsage;
    }

    return AppModel(
      id: id,
      name: name,
      packageName: packageName,
      icon: icon,
      isSystemApp: isSystemApp,
      dailyUsage: generateUsageData(30),
      weeklyUsage: generateUsageData(12),
      monthlyUsage: generateUsageData(6),
      networkUsage: generateNetworkUsage(),
    );
  }

  void setTimeRange(String timeRange) {
    _selectedTimeRange = timeRange;
    notifyListeners();
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    _customStartDate = startDate;
    _customEndDate = endDate;
    _selectedTimeRange = 'custom';
    notifyListeners();
  }

  Future<void> addSpeedLimit(SpeedLimitModel speedLimit) async {
    _speedLimits.add(speedLimit);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateSpeedLimit(SpeedLimitModel speedLimit) async {
    final index = _speedLimits.indexWhere((s) => s.id == speedLimit.id);
    if (index != -1) {
      _speedLimits[index] = speedLimit;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> removeSpeedLimit(String id) async {
    _speedLimits.removeWhere((s) => s.id == id);
    await _saveData();
    notifyListeners();
  }

  SpeedLimitModel? getSpeedLimitForNetwork(String networkId) {
    try {
      return _speedLimits.firstWhere((s) => s.networkId == networkId);
    } catch (e) {
      return null;
    }
  }

  List<AppModel> getFilteredApps(String query) {
    if (query.isEmpty) return _apps;
    return _apps.where((app) =>
        app.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<NetworkModel> getFilteredNetworks(String query) {
    if (query.isEmpty) return _networks;
    return _networks.where((network) =>
        network.name.toLowerCase().contains(query.toLowerCase()) ||
        network.ssid.toLowerCase().contains(query.toLowerCase())).toList();
  }

  double getTotalDataUsage() {
    double total = 0;
    for (final app in _apps) {
      final usage = _getUsageMapForTimeRange(app);
      for (final data in usage.values) {
        total += data.totalMB;
      }
    }
    return total;
  }

  Map<String, DataUsage> _getUsageMapForTimeRange(AppModel app) {
    switch (_selectedTimeRange) {
      case 'daily':
        return app.dailyUsage;
      case 'weekly':
        return app.weeklyUsage;
      case 'monthly':
        return app.monthlyUsage;
      default:
        return app.dailyUsage;
    }
  }
}