import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greenhouse/models/greenhouse_model.dart';
import 'package:greenhouse/providers/greenhouse_detail_provider.dart';
import 'package:greenhouse/widgets/stat_card.dart';
import 'package:greenhouse/widgets/sensor_history_tab.dart';
import 'package:greenhouse/widgets/system_history_tab.dart';

class GreenhouseHistoryScreen extends StatefulWidget {
  final Greenhouse greenhouse;

  const GreenhouseHistoryScreen({super.key, required this.greenhouse});

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
      final provider = context.read<GreenhouseDetailProvider>();
      final stats = await provider.getSensorStats(
        since: DateTime.now().subtract(const Duration(days: 1)),
      );
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (e) {
      debugPrint('Error al cargar estadísticas: $e');
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
          if (_stats != null && !_loadingStats) _StatsSection(stats: _stats!),

          if (_loadingStats)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [SensorHistoryTab(), SystemHistoryTab()],
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

class _StatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surfaceVariant.withOpacity(0.3),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas (últimas 24h)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Temp. Promedio',
                  value:
                      '${(stats['avg_temp'] as double?)?.toStringAsFixed(1) ?? '--'}°C',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Hum. Promedio',
                  value:
                      '${(stats['avg_humidity'] as double?)?.toStringAsFixed(1) ?? '--'}%',
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Registros: ${stats['count']}',
            style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
