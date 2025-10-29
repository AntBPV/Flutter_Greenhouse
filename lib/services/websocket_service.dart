import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/websocket_message.dart';
import '../models/sensor_data.dart';
import '../models/system_status.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _messageController;
  StreamController<SensorData>? _sensorController;
  StreamController<SystemStatus>? _statusController;
  StreamController<String>? _errorController;
  StreamController<bool>? _connectionController;

  String? _url;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Streams públicos
  Stream<WebSocketMessage> get messages => _messageController!.stream;
  Stream<SensorData> get sensorData => _sensorController!.stream;
  Stream<SystemStatus> get systemStatus => _statusController!.stream;
  Stream<String> get errors => _errorController!.stream;
  Stream<bool> get connectionStatus => _connectionController!.stream;

  bool get isConnected => _isConnected;

  WebSocketService() {
    _messageController = StreamController<WebSocketMessage>.broadcast();
    _sensorController = StreamController<SensorData>.broadcast();
    _statusController = StreamController<SystemStatus>.broadcast();
    _errorController = StreamController<String>.broadcast();
    _connectionController = StreamController<bool>.broadcast();
  }

  Future<void> connect(String url) async {
    _url = url;
    _reconnectAttempts = 0;
    await _connect();
  }

  Future<void> _connect() async {
    if (_isConnected) return;

    try {
      print('Conectando al WebSocket: $_url');
      _channel = WebSocketChannel.connect(Uri.parse(_url!));

      await _channel!.ready;

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController!.add(true);
      print('WebSocket conectado exitosamente');

      // Iniciar heartbeat
      _startHeartbeat();

      // Solicitar estado inicial
      sendCommand('get_status');

      // Escuchar mensajes
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      print('Error al conectar WebSocket: $e');
      _isConnected = false;
      _connectionController!.add(false);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final wsMessage = WebSocketMessage.fromJson(data);

      _messageController!.add(wsMessage);

      // Procesar según el tipo
      switch (wsMessage.type) {
        case MessageType.status:
          final status = SystemStatus.fromJson(data);
          _statusController!.add(status);
          break;

        case MessageType.sensor:
          final sensor = SensorData.fromJson(data);
          _sensorController!.add(sensor);
          break;

        case MessageType.error:
          final errorMsg = data['message'] as String? ?? 'Error desconocido';
          _errorController!.add(errorMsg);
          break;

        case MessageType.unknown:
          print('Mensaje desconocido recibido: $data');
          break;
      }
    } catch (e) {
      print('Error al procesar mensaje: $e');
      _errorController!.add('Error al procesar mensaje: $e');
    }
  }

  void _onError(error) {
    print('Error en WebSocket: $error');
    _errorController!.add('Error de conexión: $error');
    _isConnected = false;
    _connectionController!.add(false);
  }

  void _onDone() {
    print('WebSocket desconectado');
    _isConnected = false;
    _connectionController!.add(false);
    _heartbeatTimer?.cancel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Máximo de intentos de reconexión alcanzado');
      _errorController!.add('No se pudo reconectar al servidor');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      print('Intento de reconexión #$_reconnectAttempts');
      _connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        sendCommand('get_status');
      }
    });
  }

  // ==================== COMANDOS ====================

  void sendCommand(String action, {Map<String, dynamic>? additionalData}) {
    if (!_isConnected) {
      _errorController!.add('No conectado al WebSocket');
      return;
    }

    try {
      final command = {'action': action, ...?additionalData};

      final jsonCommand = jsonEncode(command);
      _channel!.sink.add(jsonCommand);
      print('Comando enviado: $jsonCommand');
    } catch (e) {
      print('Error al enviar comando: $e');
      _errorController!.add('Error al enviar comando: $e');
    }
  }

  void servoLeft() => sendCommand('servo_left');
  void servoRight() => sendCommand('servo_right');
  void ledsToggle() => sendCommand('leds_toggle');
  void ledsOn() => sendCommand('leds_on');
  void ledsOff() => sendCommand('leds_off');
  void readSensor() => sendCommand('read_sensor');
  void getStatus() => sendCommand('get_status');

  // ==================== CIERRE ====================

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    _isConnected = false;
    _connectionController!.add(false);
    print('WebSocket desconectado manualmente');
  }

  void dispose() {
    disconnect();
    _messageController?.close();
    _sensorController?.close();
    _statusController?.close();
    _errorController?.close();
    _connectionController?.close();
  }
}
