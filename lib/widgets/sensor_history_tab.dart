import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/greenhouse_detail_provider.dart';

class SensorHistoryTab extends StatelessWidget {
  const SensorHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        final history = provider.sensorHistory;

        if (history.isEmpty) {
          return const _EmptyState(message: 'No hay datos de sensores');
        }

        final cs = Theme.of(context).colorScheme;

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
                  backgroundColor: cs.primary.withOpacity(0.2),
                  child: Icon(Icons.sensors, color: cs.primary),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: cs.onSurface.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
