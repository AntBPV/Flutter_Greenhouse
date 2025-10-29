class SensorData {
  final int? id;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorData({
    this.id,
    required this.temperature,
    required this.humidity,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] as int?,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SensorData.fromDatabase(Map<String, dynamic> map) {
    return SensorData(
      id: map['id'] as int,
      temperature: map['temperature'] as double,
      humidity: map['humidity'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
