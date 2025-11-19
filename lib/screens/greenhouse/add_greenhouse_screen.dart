import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greenhouse/providers/greenhouse_manager_provider.dart';
import 'package:greenhouse/widgets/info_card.dart';

class AddGreenhouseScreen extends StatefulWidget {
  const AddGreenhouseScreen({super.key});

  @override
  State<AddGreenhouseScreen> createState() => _AddGreenhouseScreenState();
}

class _AddGreenhouseScreenState extends State<AddGreenhouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController(text: 'ws://');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveGreenhouse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final manager = context.read<GreenhouseManagerProvider>();
    final greenhouse = await manager.addGreenhouse(
      name: _nameController.text,
      websocketUrl: _urlController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    final cs = Theme.of(context).colorScheme;

    if (greenhouse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invernadero "${greenhouse.name}" añadido'),
          backgroundColor: cs.primary,
        ),
      );
      Navigator.pop(context);
    } else {
      if (manager.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(manager.error!), backgroundColor: cs.error),
        );
        manager.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Invernadero')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ilustración
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, size: 80, color: cs.primary),
              ),
            ),
            const SizedBox(height: 32),

            // Campo nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Invernadero',
                hintText: 'Ej: Invernadero Casa, Jardín Principal',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                if (v.trim().length < 3) {
                  return 'Debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo URL
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'ws://192.168.1.100:8080',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Dirección del servidor WebSocket del ESP32',
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Por favor ingresa la URL del WebSocket';
                }
                if (!v.startsWith('ws://') && !v.startsWith('wss://')) {
                  return 'Debe comenzar con ws:// o wss://';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Info Card reutilizable
            const InfoCard(
              title: 'Información',
              icon: Icons.info_outline,
              bulletPoints: [
                'Asegúrate de que el ESP32 esté conectado a la misma red',
                'Verifica que el servidor WebSocket esté activo',
                'Usa la IP local del ESP32 (ej: 192.168.1.100)',
                'El puerto debe coincidir con el configurado en el ESP32',
              ],
            ),
            const SizedBox(height: 32),

            // Botón Guardar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveGreenhouse,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_isLoading ? 'Guardando...' : 'Añadir Invernadero'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
