import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:greenhouse/models/greenhouse_model.dart';
import 'package:greenhouse/providers/greenhouse_detail_provider.dart';

class GreenhouseHistoryScreen extends StatefulWidget {
  final Greenhouse greenhouse;

  const GreenhouseHistoryScreen({Key? key, required this.greenhouse})
    : super(key: key);

  @override
  State<GreenhouseHistoryScreen> createState() =>
      _GreenhouseHistoryScreenState();
}

class _GreenhouseHistoryScreenState extends State<GreenhouseHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _stats;
  bool _loadingStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final stats = await context
          .read<GreenhouseDetailProvider>()
          .getSensorStats(
            since: DateTime.now().subtract(const Duration(days: 1)),
          );
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (e) {
      print('Error al cargar estadísticas: $e');
      setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historial'),
            Text(widget.greenhouse.name, style: const TextStyle(fontSize: 12)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.sensors), text: 'Sensores'),
            Tab(icon: Icon(Icons.settings_remote), text: 'Sistema'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Estadísticas
          if (_stats != null && !_loadingStats)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadísticas (últimas 24h)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Temp. Promedio',
                          value:
                              '${(_stats!['avg_temp'] as double?)?.toStringAsFixed(1) ?? '--'}°C',
                          icon: Icons.thermostat,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Hum. Promedio',
                          value:
                              '${(_stats!['avg_humidity'] as double?)?.toStringAsFixed(1) ?? '--'}%',
                          icon: Icons.water_drop,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registros: ${_stats!['count'] ?? 0}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          if (_loadingStats)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Contenido con tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_SensorHistoryTab(), _SystemHistoryTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<GreenhouseDetailProvider>().loadRecentHistory();
          _loadStats();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Actualizar',
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorHistoryTab extends StatelessWidget {
  const _SensorHistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        final history = provider.sensorHistory;

        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay datos de sensores',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final data = history[index];
            final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.sensors, color: Colors.blue),
                ),
                title: Row(
                  children: [
                    Icon(Icons.thermostat, size: 18, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${data.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.water_drop, size: 18, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${data.humidity.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Text(
                  dateFormat.format(data.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SystemHistoryTab extends StatelessWidget {
  const _SystemHistoryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        final history = provider.statusHistory;

        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay datos del sistema',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final status = history[index];
            final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.settings_remote, color: Colors.green),
                ),
                title: const Text(
                  'Estado del Sistema',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  dateFormat.format(status.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: Icons.settings_remote,
                          label: 'Servo',
                          value: status.servo.state.toUpperCase(),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.arrow_back,
                          label: 'Puede girar izquierda',
                          value: status.servo.canRotateLeft ? 'Sí' : 'No',
                          valueColor: status.servo.canRotateLeft
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.arrow_forward,
                          label: 'Puede girar derecha',
                          value: status.servo.canRotateRight ? 'Sí' : 'No',
                          valueColor: status.servo.canRotateRight
                              ? Colors.green
                              : Colors.red,
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.lightbulb,
                          label: 'LEDs',
                          value: status.leds.on ? 'Encendidos' : 'Apagados',
                          valueColor: status.leds.on
                              ? Colors.amber
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
