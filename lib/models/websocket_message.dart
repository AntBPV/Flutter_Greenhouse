enum MessageType { status, sensor, error, unknown }

class WebSocketMessage {
  final MessageType type;
  final Map<String, dynamic> data;

  WebSocketMessage({required this.type, required this.data});

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    MessageType messageType;

    switch (typeStr) {
      case 'status':
        messageType = MessageType.status;
        break;
      case 'sensor':
        messageType = MessageType.sensor;
        break;
      case 'error':
        messageType = MessageType.error;
        break;
      default:
        messageType = MessageType.unknown;
    }

    return WebSocketMessage(type: messageType, data: json);
  }
}
