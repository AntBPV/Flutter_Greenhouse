class ServoState {
  final String state;
  final bool canRotateLeft;
  final bool canRotateRight;

  ServoState({
    required this.state,
    required this.canRotateLeft,
    required this.canRotateRight,
  });

  factory ServoState.fromJson(Map<String, dynamic> json) {
    return ServoState(
      state: json['state'] as String,
      canRotateLeft: json['canRotateLeft'] as bool,
      canRotateRight: json['canRotateRight'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'canRotateLeft': canRotateLeft,
      'canRotateRight': canRotateRight,
    };
  }
}
