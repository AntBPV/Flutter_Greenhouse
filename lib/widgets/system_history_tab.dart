import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/greenhouse_detail_provider.dart';
import 'detail_row.dart';

class SystemHistoryTab extends StatelessWidget {
  const SystemHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        final history = provider.statusHistory;

        if (history.isEmpty) {
          return const _EmptyState(message: 'No hay datos del sistema');
        }

        final cs = Theme.of(context).colorScheme;

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
                  backgroundColor: cs.primary.withOpacity(0.2),
                  child: const Icon(Icons.settings_remote, color: Colors.green),
                ),
                title: const Text(
                  'Estado del Sistema',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  dateFormat.format(status.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailRow(
                          icon: Icons.settings_remote,
                          label: 'Servo',
                          value: status.servo.state.toUpperCase(),
                        ),
                        const SizedBox(height: 8),
                        DetailRow(
                          icon: Icons.arrow_back,
                          label: 'Puede girar izquierda',
                          value: status.servo.canRotateLeft ? 'Sí' : 'No',
                          valueColor: status.servo.canRotateLeft
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(height: 8),
                        DetailRow(
                          icon: Icons.arrow_forward,
                          label: 'Puede girar derecha',
                          value: status.servo.canRotateRight ? 'Sí' : 'No',
                          valueColor: status.servo.canRotateRight
                              ? Colors.green
                              : Colors.red,
                        ),
                        const Divider(height: 24),
                        DetailRow(
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
