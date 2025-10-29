import 'leds_state.dart';
import 'servo_state.dart';

class SystemStatus {
  final int? id;
  final ServoState servo;
  final LedsState leds;
  final DateTime timestamp;

  SystemStatus({
    this.id,
    required this.servo,
    required this.leds,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      servo: ServoState.fromJson(json['servo'] as Map<String, dynamic>),
      leds: LedsState.fromJson(json['leds'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'servo': servo.toJson(),
      'leds': leds.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'servo_state': servo.state,
      'servo_can_rotate_left': servo.canRotateLeft ? 1 : 0,
      'servo_can_rotate_right': servo.canRotateRight ? 1 : 0,
      'leds_on': leds.on ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SystemStatus.fromDatabase(Map<String, dynamic> map) {
    return SystemStatus(
      id: map['id'] as int,
      servo: ServoState(
        state: map['servo_state'] as String,
        canRotateLeft: map['servo_can_rotate_left'] == 1,
        canRotateRight: map['servo_can_rotate_right'] == 1,
      ),
      leds: LedsState(on: map['leds_on'] == 1),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
