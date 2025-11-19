import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/sensor_data.dart';
import '../models/system_status.dart';
import '../models/greenhouse_model.dart';
import '../repositories/greenhouse_repository.dart';

class GreenhouseDetailProvider with ChangeNotifier {
  final Greenhouse greenhouse;
  final GreenhouseRepository repository;

  // Estado actual
  SensorData? _currentSensorData;
  SystemStatus? _currentStatus;
  bool _isConnected = false;
  String? _lastError;
  bool _isLoading = false;

  // Historial
  List<SensorData> _sensorHistory = [];
  List<SystemStatus> _statusHistory = [];

  // Suscripciones a streams
  StreamSubscription<SensorData>? _sensorSubscription;
  StreamSubscription<SystemStatus>? _statusSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _errorSubscription;

  // Getters
  SensorData? get currentSensorData => _currentSensorData;
  SystemStatus? get currentStatus => _currentStatus;
  bool get isConnected => _isConnected;
  String? get lastError => _lastError;
  bool get isLoading => _isLoading;
  List<SensorData> get sensorHistory => _sensorHistory;
  List<SystemStatus> get statusHistory => _statusHistory;

  GreenhouseDetailProvider({
    required this.greenhouse,
    required this.repository,
  }) {
    _initialize();
  }

  void _initialize() async {
    await connect();
    _loadInitialData();
    _isLoading = true;

    // Suscribirse a streams del repository
    _sensorSubscription = repository.sensorDataStream.listen((data) {
      _currentSensorData = data;
      _addToSensorHistory(data);
      notifyListeners();
    });

    _statusSubscription = repository.statusStream.listen((status) {
      _currentStatus = status;
      _addToStatusHistory(status);
      notifyListeners();
    });

    _connectionSubscription = repository.connectionStream.listen((connected) {
      _isConnected = connected;
      if (connected) {
        _lastError = null;
      }
      notifyListeners();
    });

    _errorSubscription = repository.errorsStream.listen((error) {
      _lastError = error;
      notifyListeners();
    });

    _isLoading = false;
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar último estado desde cache del repository
      _currentSensorData = repository.latestSensorData;
      _currentStatus = repository.latestStatus;

      // Cargar historial reciente
      await loadRecentHistory();
    } catch (e) {
      _lastError = 'Error al cargar datos iniciales: $e';
      print(_lastError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addToSensorHistory(SensorData data) {
    _sensorHistory.insert(0, data);
    if (_sensorHistory.length > 100) {
      _sensorHistory.removeLast();
    }
  }

  void _addToStatusHistory(SystemStatus status) {
    _statusHistory.insert(0, status);
    if (_statusHistory.length > 50) {
      _statusHistory.removeLast();
    }
  }

  // ==================== CONEXIÓN ====================

  Future<void> connect() async {
    if (_isConnected) return;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await repository.connect();
      _isConnected = true;
      // _isConnected = true; forzar el estado tras conexión
      notifyListeners();
    } catch (e) {
      _lastError = 'Error al conectar: $e';
      // _isConnected = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await repository.disconnect();
  }

  // ==================== COMANDOS ====================

  void servoLeft() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.servoLeft();
  }

  void servoRight() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.servoRight();
  }

  void ledsToggle() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.ledsToggle();
  }

  void ledsOn() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.ledsOn();
  }

  void ledsOff() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.ledsOff();
  }

  void readSensor() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.readSensor();
  }

  void getStatus() {
    if (!_isConnected) {
      _lastError = 'No conectado';
      notifyListeners();
      return;
    }
    repository.getStatus();
  }

  // ==================== HISTORIAL ====================

  Future<void> loadRecentHistory({int hours = 24}) async {
    try {
      _sensorHistory = await repository.getSensorDataLastHours(hours);
      _statusHistory = await repository.getStatusHistory(limit: 50);
      notifyListeners();
    } catch (e) {
      print('Error al cargar historial: $e');
    }
  }

  Future<void> loadTodayData() async {
    try {
      _sensorHistory = await repository.getSensorDataToday();
      notifyListeners();
    } catch (e) {
      print('Error al cargar datos de hoy: $e');
    }
  }

  Future<Map<String, dynamic>> getSensorStats({DateTime? since}) async {
    return await repository.getSensorStats(since: since);
  }

  // ==================== MANTENIMIENTO ====================

  Future<void> cleanOldData({int keepDays = 7}) async {
    await repository.cleanOldData(keepDays: keepDays);
  }

  Future<void> clearAllData() async {
    await repository.clearAllData();
    _currentSensorData = null;
    _currentStatus = null;
    _sensorHistory.clear();
    _statusHistory.clear();
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ==================== DISPOSE ====================

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _statusSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    // NO llamamos repository.dispose() aquí porque lo maneja el GreenhouseManagerProvider
    super.dispose();
  }
}
