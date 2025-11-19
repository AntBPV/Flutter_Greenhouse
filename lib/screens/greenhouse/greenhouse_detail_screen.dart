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

  const GreenhouseDetailScreen({super.key, required this.greenhouse});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<GreenhouseManagerProvider>();
    final repository = manager.getRepository(greenhouse.id);

    // Si el repositorio aún no existe, conectar automáticamente
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greenhouse.name, style: textTheme.titleMedium),
            Text(
              greenhouse.websocketUrl,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver Historial',
            onPressed: () {
              final detailProvider = context.read<GreenhouseDetailProvider>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: detailProvider,
                    child: GreenhouseHistoryScreen(greenhouse: greenhouse),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              final provider = context.read<GreenhouseDetailProvider>();
              provider.getStatus();
              provider.readSensor();
            },
          ),
        ],
      ),
      body: Consumer<GreenhouseDetailProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              provider.getStatus();
              provider.readSensor();
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Estado de conexión
                  ConnectionWidgetDetail(greenhouse: greenhouse),
                  const SizedBox(height: 16),

                  // Error visible
                  if (provider.lastError != null)
                    _ErrorMessage(
                      message: provider.lastError!,
                      onClear: provider.clearError,
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

class _ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onClear;

  const _ErrorMessage({required this.message, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClear,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
