class DataUsage {
  final double downloadMB;
  final double uploadMB;
  final DateTime timestamp;

  DataUsage({
    required this.downloadMB,
    required this.uploadMB,
    required this.timestamp,
  });

  double get totalMB => downloadMB + uploadMB;

  Map<String, dynamic> toJson() => {
    'downloadMB': downloadMB,
    'uploadMB': uploadMB,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DataUsage.fromJson(Map<String, dynamic> json) => DataUsage(
    downloadMB: json['downloadMB'],
    uploadMB: json['uploadMB'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}