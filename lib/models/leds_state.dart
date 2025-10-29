class LedsState {
  final bool on;

  LedsState({required this.on});

  factory LedsState.fromJson(Map<String, dynamic> json) {
    return LedsState(on: json['on'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'on': on};
  }
}
