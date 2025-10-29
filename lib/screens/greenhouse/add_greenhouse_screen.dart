import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greenhouse/providers/greenhouse_manager_provider.dart';

class AddGreenhouseScreen extends StatefulWidget {
  const AddGreenhouseScreen({Key? key}) : super(key: key);

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final manager = context.read<GreenhouseManagerProvider>();
    final greenhouse = await manager.addGreenhouse(
      name: _nameController.text,
      websocketUrl: _urlController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (greenhouse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invernadero "${greenhouse.name}" añadido'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      // Mostrar error del manager
      if (manager.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(manager.error!), backgroundColor: Colors.red),
        );
        manager.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, size: 80, color: Colors.green.shade400),
              ),
            ),
            const SizedBox(height: 32),

            // Campo de nombre
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo de URL
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
                helperMaxLines: 2,
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa la URL del WebSocket';
                }
                if (!value.startsWith('ws://') && !value.startsWith('wss://')) {
                  return 'La URL debe comenzar con ws:// o wss://';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Información adicional
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Asegúrate de que el ESP32 esté conectado a la misma red\n'
                      '• Verifica que el servidor WebSocket esté activo\n'
                      '• Usa la IP local del ESP32 (ej: 192.168.1.100)\n'
                      '• El puerto debe coincidir con el configurado en el ESP32',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón de guardar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveGreenhouse,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add),
              label: Text(_isLoading ? 'Guardando...' : 'Añadir Invernadero'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
