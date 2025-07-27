class SpeedLimitModel {
  final String id;
  final String networkId;
  final bool isEnabled;
  final double downloadLimitKbps;
  final double uploadLimitKbps;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SpeedLimitModel({
    required this.id,
    required this.networkId,
    required this.isEnabled,
    required this.downloadLimitKbps,
    required this.uploadLimitKbps,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'networkId': networkId,
    'isEnabled': isEnabled,
    'downloadLimitKbps': downloadLimitKbps,
    'uploadLimitKbps': uploadLimitKbps,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory SpeedLimitModel.fromJson(Map<String, dynamic> json) => SpeedLimitModel(
    id: json['id'],
    networkId: json['networkId'],
    isEnabled: json['isEnabled'],
    downloadLimitKbps: json['downloadLimitKbps'],
    uploadLimitKbps: json['uploadLimitKbps'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : null,
  );

  SpeedLimitModel copyWith({
    String? id,
    String? networkId,
    bool? isEnabled,
    double? downloadLimitKbps,
    double? uploadLimitKbps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SpeedLimitModel(
    id: id ?? this.id,
    networkId: networkId ?? this.networkId,
    isEnabled: isEnabled ?? this.isEnabled,
    downloadLimitKbps: downloadLimitKbps ?? this.downloadLimitKbps,
    uploadLimitKbps: uploadLimitKbps ?? this.uploadLimitKbps,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}