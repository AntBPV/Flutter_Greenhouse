import 'dart:async';
import '../models/sensor_data.dart';
import '../models/system_status.dart';
import '../models/greenhouse_model.dart';
import '../services/sqlite_service.dart';
import '../services/websocket_service.dart';

class GreenhouseRepository {
  final Greenhouse greenhouse;
  final WebSocketService _websocketService;
  final SQLiteService _databaseService;

  Timer? _periodicSaveTimer;
  static const Duration _saveInterval = Duration(minutes: 5);

  // Cache en memoria del último estado
  SensorData? _latestSensorData;
  SystemStatus? _latestStatus;

  // Getters para cache
  SensorData? get latestSensorData => _latestSensorData;
  SystemStatus? get latestStatus => _latestStatus;

  // Streams del WebSocket
  Stream<SensorData> get sensorDataStream => _websocketService.sensorData;
  Stream<SystemStatus> get statusStream => _websocketService.systemStatus;
  Stream<String> get errorsStream => _websocketService.errors;
  Stream<bool> get connectionStream => _websocketService.connectionStatus;

  bool get isConnected => _websocketService.isConnected;

  GreenhouseRepository({
    required this.greenhouse,
    required SQLiteService databaseService,
  }) : _websocketService = WebSocketService(),
       _databaseService = databaseService {
    _initialize();
  }

  void _initialize() {
    // Escuchar datos del sensor y actualizar cache + DB
    _websocketService.sensorData.listen((data) {
      _latestSensorData = data;
      _saveSensorDataToDb(data);
    });

    // Escuchar estado del sistema y actualizar cache + DB
    _websocketService.systemStatus.listen((status) {
      _latestStatus = status;
      _saveStatusToDb(status);
    });

    // Guardar periódicamente el estado actual
    _startPeriodicSave();

    // Cargar último estado desde DB al inicializar
    _loadLatestFromDatabase();
  }

  Future<void> _loadLatestFromDatabase() async {
    try {
      _latestSensorData = await _databaseService.getLatestSensorData(
        greenhouse.id,
      );
      _latestStatus = await _databaseService.getLatestStatus(greenhouse.id);
      print('Estado cargado desde base de datos para ${greenhouse.name}');
    } catch (e) {
      print('Error al cargar estado desde DB: $e');
    }
  }

  void _startPeriodicSave() {
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = Timer.periodic(_saveInterval, (timer) {
      // Solicitar estado actual al ESP32
      if (_websocketService.isConnected) {
        _websocketService.readSensor();
        _websocketService.getStatus();
      }
    });
  }

  Future<void> _saveSensorDataToDb(SensorData data) async {
    try {
      await _databaseService.insertSensorData(greenhouse.id, data);
      print('Datos del sensor guardados en DB para ${greenhouse.name}');
    } catch (e) {
      print('Error al guardar datos del sensor: $e');
    }
  }

  Future<void> _saveStatusToDb(SystemStatus status) async {
    try {
      await _databaseService.insertSystemStatus(greenhouse.id, status);
      print('Estado del sistema guardado en DB para ${greenhouse.name}');
    } catch (e) {
      print('Error al guardar estado del sistema: $e');
    }
  }

  // ==================== CONEXIÓN ====================

  Future<void> connect() async {
    await _websocketService.connect(greenhouse.websocketUrl);
    // Actualizar última conexión en DB
    await _databaseService.updateGreenhouseLastConnection(greenhouse.id);
  }

  Future<void> disconnect() async {
    await _websocketService.disconnect();
  }

  // ==================== COMANDOS ====================

  void servoLeft() => _websocketService.servoLeft();
  void servoRight() => _websocketService.servoRight();
  void ledsToggle() => _websocketService.ledsToggle();
  void ledsOn() => _websocketService.ledsOn();
  void ledsOff() => _websocketService.ledsOff();
  void readSensor() => _websocketService.readSensor();
  void getStatus() => _websocketService.getStatus();

  // ==================== DATOS HISTÓRICOS ====================

  Future<List<SensorData>> getSensorHistory({
    int limit = 100,
    DateTime? since,
  }) async {
    return await _databaseService.getSensorDataHistory(
      greenhouseId: greenhouse.id,
      limit: limit,
      since: since,
    );
  }

  Future<List<SystemStatus>> getStatusHistory({
    int limit = 50,
    DateTime? since,
  }) async {
    return await _databaseService.getStatusHistory(
      greenhouseId: greenhouse.id,
      limit: limit,
      since: since,
    );
  }

  Future<Map<String, dynamic>> getSensorStats({DateTime? since}) async {
    return await _databaseService.getSensorStats(
      greenhouseId: greenhouse.id,
      since: since,
    );
  }

  // Obtener datos de las últimas N horas
  Future<List<SensorData>> getSensorDataLastHours(int hours) async {
    final since = DateTime.now().subtract(Duration(hours: hours));
    return await getSensorHistory(since: since);
  }

  // Obtener datos del día actual
  Future<List<SensorData>> getSensorDataToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return await getSensorHistory(since: startOfDay);
  }

  // ==================== MANTENIMIENTO ====================

  Future<void> cleanOldData({int keepDays = 7}) async {
    try {
      final deletedSensor = await _databaseService.cleanOldSensorData(
        greenhouseId: greenhouse.id,
        keepDays: keepDays,
      );
      final deletedStatus = await _databaseService.cleanOldStatus(
        greenhouseId: greenhouse.id,
        keepDays: keepDays,
      );
      print(
        'Limpieza completada para ${greenhouse.name}: $deletedSensor sensores, $deletedStatus estados eliminados',
      );
    } catch (e) {
      print('Error al limpiar datos antiguos: $e');
    }
  }

  Future<void> clearAllData() async {
    await _databaseService.clearAllDataForGreenhouse(greenhouse.id);
    _latestSensorData = null;
    _latestStatus = null;
  }

  // ==================== DISPOSE ====================

  void dispose() {
    _periodicSaveTimer?.cancel();
    _websocketService.dispose();
  }
}
