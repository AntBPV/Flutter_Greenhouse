import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sensor_data.dart';
import '../models/system_status.dart';
import '../models/greenhouse_model.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'greenhouses_data.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de invernaderos
    await db.execute('''
      CREATE TABLE greenhouses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        websocket_url TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        last_connection INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla para datos del sensor (con greenhouse_id)
    await db.execute('''
      CREATE TABLE sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        greenhouse_id TEXT NOT NULL,
        temperature REAL NOT NULL,
        humidity REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (greenhouse_id) REFERENCES greenhouses (id) ON DELETE CASCADE
      )
    ''');

    // Tabla para estado del sistema (con greenhouse_id)
    await db.execute('''
      CREATE TABLE system_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        greenhouse_id TEXT NOT NULL,
        servo_state TEXT NOT NULL,
        servo_can_rotate_left INTEGER NOT NULL,
        servo_can_rotate_right INTEGER NOT NULL,
        leds_on INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (greenhouse_id) REFERENCES greenhouses (id) ON DELETE CASCADE
      )
    ''');

    // Índices para mejorar consultas
    await db.execute('''
      CREATE INDEX idx_sensor_greenhouse_timestamp 
      ON sensor_data(greenhouse_id, timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_status_greenhouse_timestamp 
      ON system_status(greenhouse_id, timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_greenhouses_active 
      ON greenhouses(is_active)
    ''');
  }

  // ==================== GREENHOUSES ====================

  Future<int> insertGreenhouse(Greenhouse greenhouse) async {
    final db = await database;
    await db.insert(
      'greenhouses',
      greenhouse.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return 1;
  }

  Future<List<Greenhouse>> getAllGreenhouses({bool onlyActive = false}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'greenhouses',
      where: onlyActive ? 'is_active = ?' : null,
      whereArgs: onlyActive ? [1] : null,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Greenhouse.fromDatabase(map)).toList();
  }

  Future<Greenhouse?> getGreenhouse(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'greenhouses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Greenhouse.fromDatabase(maps.first);
  }

  Future<int> updateGreenhouse(Greenhouse greenhouse) async {
    final db = await database;
    return await db.update(
      'greenhouses',
      greenhouse.toDatabase(),
      where: 'id = ?',
      whereArgs: [greenhouse.id],
    );
  }

  Future<int> updateGreenhouseLastConnection(String id) async {
    final db = await database;
    return await db.update(
      'greenhouses',
      {'last_connection': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGreenhouse(String id) async {
    final db = await database;
    // Las foreign keys con CASCADE eliminarán automáticamente los datos relacionados
    return await db.delete('greenhouses', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SENSOR DATA ====================

  Future<int> insertSensorData(String greenhouseId, SensorData data) async {
    final db = await database;
    final dataMap = data.toDatabase();
    dataMap['greenhouse_id'] = greenhouseId;
    return await db.insert('sensor_data', dataMap);
  }

  Future<List<SensorData>> getSensorDataHistory({
    required String greenhouseId,
    int limit = 100,
    DateTime? since,
  }) async {
    final db = await database;

    String whereClause = 'greenhouse_id = ?';
    List<dynamic> whereArgs = [greenhouseId];

    if (since != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(since.millisecondsSinceEpoch);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'sensor_data',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => SensorData.fromDatabase(map)).toList();
  }

  Future<SensorData?> getLatestSensorData(String greenhouseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sensor_data',
      where: 'greenhouse_id = ?',
      whereArgs: [greenhouseId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SensorData.fromDatabase(maps.first);
  }

  Future<int> cleanOldSensorData({
    required String greenhouseId,
    int keepDays = 7,
  }) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: keepDays))
        .millisecondsSinceEpoch;

    return await db.delete(
      'sensor_data',
      where: 'greenhouse_id = ? AND timestamp < ?',
      whereArgs: [greenhouseId, cutoffTime],
    );
  }

  // ==================== SYSTEM STATUS ====================

  Future<int> insertSystemStatus(
    String greenhouseId,
    SystemStatus status,
  ) async {
    final db = await database;
    final statusMap = status.toDatabase();
    statusMap['greenhouse_id'] = greenhouseId;
    return await db.insert('system_status', statusMap);
  }

  Future<List<SystemStatus>> getStatusHistory({
    required String greenhouseId,
    int limit = 50,
    DateTime? since,
  }) async {
    final db = await database;

    String whereClause = 'greenhouse_id = ?';
    List<dynamic> whereArgs = [greenhouseId];

    if (since != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(since.millisecondsSinceEpoch);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'system_status',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => SystemStatus.fromDatabase(map)).toList();
  }

  Future<SystemStatus?> getLatestStatus(String greenhouseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'system_status',
      where: 'greenhouse_id = ?',
      whereArgs: [greenhouseId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SystemStatus.fromDatabase(maps.first);
  }

  Future<int> cleanOldStatus({
    required String greenhouseId,
    int keepDays = 7,
  }) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: keepDays))
        .millisecondsSinceEpoch;

    return await db.delete(
      'system_status',
      where: 'greenhouse_id = ? AND timestamp < ?',
      whereArgs: [greenhouseId, cutoffTime],
    );
  }

  // ==================== ESTADÍSTICAS ====================

  Future<Map<String, dynamic>> getSensorStats({
    required String greenhouseId,
    DateTime? since,
  }) async {
    final db = await database;

    String whereClause = 'greenhouse_id = ?';
    List<dynamic> whereArgs = [greenhouseId];

    if (since != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(since.millisecondsSinceEpoch);
    }

    final result = await db.rawQuery('''
      SELECT 
        AVG(temperature) as avg_temp,
        MIN(temperature) as min_temp,
        MAX(temperature) as max_temp,
        AVG(humidity) as avg_humidity,
        MIN(humidity) as min_humidity,
        MAX(humidity) as max_humidity,
        COUNT(*) as count
      FROM sensor_data
      WHERE $whereClause
    ''', whereArgs);

    return result.first;
  }

  // ==================== UTILIDADES ====================

  Future<void> clearAllDataForGreenhouse(String greenhouseId) async {
    final db = await database;
    await db.delete(
      'sensor_data',
      where: 'greenhouse_id = ?',
      whereArgs: [greenhouseId],
    );
    await db.delete(
      'system_status',
      where: 'greenhouse_id = ?',
      whereArgs: [greenhouseId],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('sensor_data');
    await db.delete('system_status');
    await db.delete('greenhouses');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
