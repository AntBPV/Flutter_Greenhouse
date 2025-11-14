import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:greenhouse/models/greenhouse_model.dart';
import 'package:greenhouse/providers/greenhouse_manager_provider.dart';

class GreenhouseCard extends StatelessWidget {
  final Greenhouse greenhouse;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GreenhouseCard({
    super.key,
    required this.greenhouse,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<GreenhouseManagerProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isConnected = manager.isGreenhouseConnected(greenhouse.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIcon(colorScheme),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTitleSection(isConnected, context)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    greenhouse.lastConnection != null
                        ? 'Última conexión: ${dateFormat.format(greenhouse.lastConnection!)}'
                        : 'Sin conexiones previas',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.eco, color: cs.primary, size: 32),
    );
  }

  Widget _buildTitleSection(bool isConnected, BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                greenhouse.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _ConnectionStatus(isConnected: isConnected),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          greenhouse.websocketUrl,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool isConnected;

  const _ConnectionStatus({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected
            ? cs.secondaryContainer
            : cs.surfaceVariant.withAlpha(90),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isConnected ? cs.secondary : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Conectado' : 'Desconectado',
            style: TextStyle(
              fontSize: 12,
              color: isConnected ? cs.secondary : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
