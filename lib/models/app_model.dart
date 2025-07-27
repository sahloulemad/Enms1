import 'package:enms/models/data_usage.dart';

class AppModel {
  final String id;
  final String name;
  final String packageName;
  final String icon;
  final bool isSystemApp;
  final Map<String, DataUsage> dailyUsage;
  final Map<String, DataUsage> weeklyUsage;
  final Map<String, DataUsage> monthlyUsage;
  final Map<String, Map<String, DataUsage>> networkUsage;

  AppModel({
    required this.id,
    required this.name,
    required this.packageName,
    required this.icon,
    required this.isSystemApp,
    required this.dailyUsage,
    required this.weeklyUsage,
    required this.monthlyUsage,
    required this.networkUsage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'packageName': packageName,
    'icon': icon,
    'isSystemApp': isSystemApp,
    'dailyUsage': dailyUsage.map((k, v) => MapEntry(k, v.toJson())),
    'weeklyUsage': weeklyUsage.map((k, v) => MapEntry(k, v.toJson())),
    'monthlyUsage': monthlyUsage.map((k, v) => MapEntry(k, v.toJson())),
    'networkUsage': networkUsage.map((k, v) => 
        MapEntry(k, v.map((k2, v2) => MapEntry(k2, v2.toJson())))),
  };

  factory AppModel.fromJson(Map<String, dynamic> json) => AppModel(
    id: json['id'],
    name: json['name'],
    packageName: json['packageName'],
    icon: json['icon'],
    isSystemApp: json['isSystemApp'],
    dailyUsage: (json['dailyUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, DataUsage.fromJson(v))),
    weeklyUsage: (json['weeklyUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, DataUsage.fromJson(v))),
    monthlyUsage: (json['monthlyUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, DataUsage.fromJson(v))),
    networkUsage: (json['networkUsage'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as Map<String, dynamic>)
            .map((k2, v2) => MapEntry(k2, DataUsage.fromJson(v2))))),
  );
}