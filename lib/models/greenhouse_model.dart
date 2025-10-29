class Greenhouse {
  final String id;
  final String name;
  final String websocketUrl;
  final DateTime createdAt;
  final DateTime? lastConnection;
  final bool isActive;

  Greenhouse({
    required this.id,
    required this.name,
    required this.websocketUrl,
    DateTime? createdAt,
    this.lastConnection,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // Generar ID único
  factory Greenhouse.create({
    required String name,
    required String websocketUrl,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final id = 'greenhouse_$timestamp';

    return Greenhouse(id: id, name: name, websocketUrl: websocketUrl);
  }

  Greenhouse copyWith({
    String? name,
    String? websocketUrl,
    DateTime? lastConnection,
    bool? isActive,
  }) {
    return Greenhouse(
      id: id,
      name: name ?? this.name,
      websocketUrl: websocketUrl ?? this.websocketUrl,
      createdAt: createdAt,
      lastConnection: lastConnection ?? this.lastConnection,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'websocketUrl': websocketUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastConnection': lastConnection?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'websocket_url': websocketUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_connection': lastConnection?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Greenhouse.fromDatabase(Map<String, dynamic> map) {
    return Greenhouse(
      id: map['id'] as String,
      name: map['name'] as String,
      websocketUrl: map['websocket_url'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastConnection: map['last_connection'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_connection'] as int)
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  @override
  String toString() => 'Greenhouse(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Greenhouse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
