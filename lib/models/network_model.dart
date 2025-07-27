import 'package:enms/models/data_usage.dart';

class NetworkModel {
  final String id;
  final String name;
  final String ssid;
  final bool isConnected;
  final int signalStrength;
  final String securityType;
  final Map<String, DataUsage> dailyUsage;
  final Map<String, DataUsage> weeklyUsage;
  final Map<String, DataUsage> monthlyUsage;

  NetworkModel({
    required this.id,
    required this.name,
    required this.ssid,
    required this.isConnected,
    required this.signalStrength,
    required this.securityType,
    required this.dailyUsage,
    required this.weeklyUsage,
    required this.monthlyUsage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ssid': ssid,
    'isConnected': isConnected,
    'signalStrength': signalStrength,
    'securityType': securityType,
    'dailyUsage': dailyUsage.map((k, v) => MapEntry(k, v.toJson())),
    'weeklyUsage': weeklyUsage.map((k, v) => MapEntry(k, v.toJson())),
    'monthlyUsage': monthlyUsage.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory NetworkModel.fromJson(Map<String, dynamic> json) => NetworkModel(
    id: json['id'],
    name: json['name'],
    ssid: json['ssid'],
    isConnected: json['isConnected'],
    signalStrength: json['signalStrength'],
    securityType: json['securityType'],
    dailyUsage: (json['dailyUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, DataUsage.fromJson(v))),
    weeklyUsage: (json['weeklyUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, DataUsage.fromJson(v))),
    monthlyUsage: (json['monthlyUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, DataUsage.fromJson(v))),
  );
}