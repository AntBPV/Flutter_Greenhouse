import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greenhouse/providers/greenhouse_detail_provider.dart';
import 'package:greenhouse/providers/greenhouse_manager_provider.dart';
import 'package:greenhouse/models/greenhouse_model.dart';
import 'package:greenhouse/widgets/connection_widget_detail.dart';
import 'package:greenhouse/widgets/sensor_display.dart';
import 'package:greenhouse/widgets/control_panel.dart';
import 'package:greenhouse/widgets/status_display.dart';
import 'greenhouse_history_screen.dart';

class GreenhouseDetailScreen extends StatelessWidget {
  final Greenhouse greenhouse;

  const GreenhouseDetailScreen({Key? key, required this.greenhouse})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<GreenhouseManagerProvider>();
    final repository = manager.getRepository(greenhouse.id);

    // Si no existe el repository, crearlo conectando el invernadero
    if (repository == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        manager.connectGreenhouse(greenhouse.id);
      });
      return Scaffold(
        appBar: AppBar(title: Text(greenhouse.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => GreenhouseDetailProvider(
        greenhouse: greenhouse,
        repository: repository,
      ),
      child: _GreenhouseDetailContent(greenhouse: greenhouse),
    );
  }
}

class _GreenhouseDetailContent extends StatelessWidget {
  final Greenhouse greenhouse;

  const _GreenhouseDetailContent({required this.greenhouse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greenhouse.name),
            Text(greenhouse.websocketUrl, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              final detailProvider = context.read<GreenhouseDetailProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: detailProvider, // ← Compartir el provider existente
                    child: GreenhouseHistoryScreen(greenhouse: greenhouse),
                  ),
                ),
              );
            },
            tooltip: 'Ver Historial',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GreenhouseDetailProvider>().getStatus();
              context.read<GreenhouseDetailProvider>().readSensor();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<GreenhouseDetailProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              provider.getStatus();
              provider.readSensor();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Widget de conexión
                  ConnectionWidgetDetail(greenhouse: greenhouse),
                  const SizedBox(height: 16),

                  // Mensaje de error si existe
                  if (provider.lastError != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                provider.lastError!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: provider.clearError,
                              color: Colors.red.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (provider.lastError != null) const SizedBox(height: 16),

                  // Datos del sensor
                  const SensorDisplay(),
                  const SizedBox(height: 16),

                  // Estado del sistema
                  const StatusDisplay(),
                  const SizedBox(height: 16),

                  // Panel de control
                  const ControlPanel(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
