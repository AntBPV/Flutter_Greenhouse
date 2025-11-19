import 'package:flutter/material.dart';
import 'package:greenhouse/models/greenhouse_model.dart';
import 'package:provider/provider.dart';
import 'package:greenhouse/providers/greenhouse_manager_provider.dart';
import 'package:greenhouse/widgets/greenhouse_card.dart';
import 'greenhouse_detail_screen.dart';
import 'add_greenhouse_screen.dart';

class GreenhousesListScreen extends StatelessWidget {
  const GreenhousesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Invernaderos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<GreenhouseManagerProvider>().refresh(),
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
            return _ErrorView(error: manager.error!, onRetry: manager.refresh);
          }

          if (manager.greenhouses.isEmpty) {
            return _EmptyState(onAdd: () => _showAddGreenhouseScreen(context));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: manager.greenhouses.length,
            itemBuilder: (context, index) {
              final greenhouse = manager.greenhouses[index];
              return GreenhouseCard(
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
      MaterialPageRoute(builder: (_) => const AddGreenhouseScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, Greenhouse greenhouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GreenhouseDetailScreen(greenhouse: greenhouse),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Greenhouse greenhouse) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Invernadero'),
        content: Text(
          '¿Deseas eliminar "${greenhouse.name}"?\n\n'
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
                  backgroundColor: cs.error,
                ),
              );
            },
            child: Text('Eliminar', style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: cs.error),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 100, color: cs.primary),
          const SizedBox(height: 24),
          Text(
            'No tienes invernaderos',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tu primer invernadero\npara comenzar',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Añadir Invernadero'),
          ),
        ],
      ),
    );
  }
}
