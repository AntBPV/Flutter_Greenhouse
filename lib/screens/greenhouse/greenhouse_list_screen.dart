import 'package:flutter/material.dart';
import 'package:greenhouse/models/greenhouse_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:greenhouse/providers/greenhouse_manager_provider.dart';
import 'greenhouse_detail_screen.dart';
import 'add_greenhouse_screen.dart';

class GreenhousesListScreen extends StatelessWidget {
  const GreenhousesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Invernaderos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GreenhouseManagerProvider>().refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<GreenhouseManagerProvider>(
        builder: (context, manager, child) {
          if (manager.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    manager.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => manager.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (manager.greenhouses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 100,
                    color: Colors.green.shade200,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No tienes invernaderos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Añade tu primer invernadero\npara comenzar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddGreenhouseScreen(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir Invernadero'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: manager.greenhouses.length,
            itemBuilder: (context, index) {
              final greenhouse = manager.greenhouses[index];
              return _GreenhouseCard(
                greenhouse: greenhouse,
                onTap: () => _navigateToDetail(context, greenhouse),
                onDelete: () => _confirmDelete(context, greenhouse),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGreenhouseScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
    );
  }

  void _showAddGreenhouseScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGreenhouseScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, Greenhouse greenhouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GreenhouseDetailScreen(greenhouse: greenhouse),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Greenhouse greenhouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Invernadero'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${greenhouse.name}"?\n\n'
          'Se eliminarán todos los datos históricos asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GreenhouseManagerProvider>().deleteGreenhouse(
                greenhouse.id,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${greenhouse.name} eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _GreenhouseCard extends StatelessWidget {
  final Greenhouse greenhouse;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GreenhouseCard({
    required this.greenhouse,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<GreenhouseManagerProvider>();
    final isConnected = manager.isGreenhouseConnected(greenhouse.id);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: Colors.green.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                greenhouse.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isConnected
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isConnected ? 'Conectado' : 'Desconectado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isConnected
                                          ? Colors.green.shade700
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          greenhouse.websocketUrl,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    greenhouse.lastConnection != null
                        ? 'Última conexión: ${dateFormat.format(greenhouse.lastConnection!)}'
                        : 'Sin conexiones previas',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade400,
                    onPressed: onDelete,
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
