import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/greenhouse_detail_provider.dart';
import '../models/greenhouse_model.dart';

class ConnectionWidgetDetail extends StatelessWidget {
  final Greenhouse greenhouse;

  const ConnectionWidgetDetail({Key? key, required this.greenhouse})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        return Card(
          color: theme.cardColor,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      provider.isConnected ? Icons.check_circle : Icons.cancel,
                      color: provider.isConnected ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.isConnected ? 'Conectado' : 'Desconectado',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            greenhouse.websocketUrl,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!provider.isConnected)
                      ElevatedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                await provider.connect();
                              },
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.link),
                        label: Text(
                          provider.isLoading ? 'Conectando...' : 'Conectar',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    if (provider.isConnected)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await provider.disconnect();
                        },
                        icon: const Icon(Icons.link_off),
                        label: const Text('Desconectar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
