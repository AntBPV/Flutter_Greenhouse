import 'package:flutter/foundation.dart';
import '../models/greenhouse_model.dart';
import '../services/sqlite_service.dart';
import '../repositories/greenhouse_repository.dart';

class GreenhouseManagerProvider with ChangeNotifier {
  final SQLiteService _databaseService;

  List<Greenhouse> _greenhouses = [];
  Map<String, GreenhouseRepository> _repositories = {};
  bool _isLoading = false;
  String? _error;

  List<Greenhouse> get greenhouses => _greenhouses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GreenhouseManagerProvider(this._databaseService) {
    _loadGreenhouses();
  }

  Future<void> _loadGreenhouses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _greenhouses = await _databaseService.getAllGreenhouses();
      print('Cargados ${_greenhouses.length} invernaderos');
    } catch (e) {
      _error = 'Error al cargar invernaderos: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener repository de un invernadero específico
  GreenhouseRepository? getRepository(String greenhouseId) {
    return _repositories[greenhouseId];
  }

  // Crear o actualizar repository
  GreenhouseRepository _getOrCreateRepository(Greenhouse greenhouse) {
    if (!_repositories.containsKey(greenhouse.id)) {
      _repositories[greenhouse.id] = GreenhouseRepository(
        greenhouse: greenhouse,
        databaseService: _databaseService,
      );
    }
    return _repositories[greenhouse.id]!;
  }

  // ==================== CRUD DE INVERNADEROS ====================

  Future<Greenhouse?> addGreenhouse({
    required String name,
    required String websocketUrl,
  }) async {
    try {
      if (name.trim().isEmpty) {
        _error = 'El nombre no puede estar vacío';
        notifyListeners();
        return null;
      }

      if (websocketUrl.trim().isEmpty) {
        _error = 'La URL del WebSocket no puede estar vacía';
        notifyListeners();
        return null;
      }

      if (!websocketUrl.startsWith('ws://') &&
          !websocketUrl.startsWith('wss://')) {
        _error = 'La URL debe comenzar con ws:// o wss://';
        notifyListeners();
        return null;
      }

      final greenhouse = Greenhouse.create(
        name: name.trim(),
        websocketUrl: websocketUrl.trim(),
      );

      await _databaseService.insertGreenhouse(greenhouse);
      await _loadGreenhouses();

      _error = null;
      notifyListeners();

      return greenhouse;
    } catch (e) {
      _error = 'Error al añadir invernadero: $e';
      print(_error);
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateGreenhouse(Greenhouse greenhouse) async {
    try {
      await _databaseService.updateGreenhouse(greenhouse);

      // Si está conectado, desconectar el viejo repository
      final oldRepo = _repositories[greenhouse.id];
      if (oldRepo != null) {
        await oldRepo.disconnect();
        oldRepo.dispose();
        _repositories.remove(greenhouse.id);
      }

      await _loadGreenhouses();
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar invernadero: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGreenhouse(String greenhouseId) async {
    try {
      // Desconectar y limpiar repository si existe
      final repo = _repositories[greenhouseId];
      if (repo != null) {
        repo.dispose();
        _repositories.remove(greenhouseId);
        await repo.disconnect();
      }

      // Eliminar de la base de datos (esto también elimina todos los datos relacionados)
      await _databaseService.deleteGreenhouse(greenhouseId);
      await _loadGreenhouses();

      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Error al eliminar invernadero: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  // ==================== CONEXIÓN ====================

  Future<void> connectGreenhouse(String greenhouseId) async {
    try {
      final greenhouse = _greenhouses.firstWhere((g) => g.id == greenhouseId);
      final repo = _getOrCreateRepository(greenhouse);
      await repo.connect();
      notifyListeners();
    } catch (e) {
      _error = 'Error al conectar: $e';
      print(_error);
      notifyListeners();
    }
  }

  Future<void> disconnectGreenhouse(String greenhouseId) async {
    try {
      final repo = _repositories[greenhouseId];
      if (repo != null) {
        await repo.disconnect();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al desconectar: $e';
      print(_error);
      notifyListeners();
    }
  }

  // Verificar si un invernadero está conectado
  bool isGreenhouseConnected(String greenhouseId) {
    final repo = _repositories[greenhouseId];
    return repo?.isConnected ?? false;
  }

  // ==================== UTILIDADES ====================

  Future<void> refresh() async {
    await _loadGreenhouses();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Greenhouse? getGreenhouseById(String id) {
    try {
      return _greenhouses.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== DISPOSE ====================

  @override
  void dispose() {
    // Desconectar y limpiar todos los repositories
    for (var repo in _repositories.values) {
      repo.disconnect();
      repo.dispose();
    }
    _repositories.clear();
    super.dispose();
  }
}
