import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Importar la pantalla de lista de invernaderos
import './greenhouse/greenhouse_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Greenhouse App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información del usuario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                user?.email ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título de secciones
            const Text(
              'Gestión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tarjeta de Invernaderos
            _MenuCard(
              icon: Icons.eco,
              title: 'Mis Invernaderos',
              subtitle: 'Gestiona y monitorea tus sistemas ESP32',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GreenhousesListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Aquí puedes añadir más opciones del menú
            _MenuCard(
              icon: Icons.settings,
              title: 'Configuración',
              subtitle: 'Ajustes de la aplicación',
              color: Colors.blue,
              onTap: () {
                // Navegar a configuración
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente...')),
                );
              },
            ),
            const SizedBox(height: 12),

            _MenuCard(
              icon: Icons.info,
              title: 'Acerca de',
              subtitle: 'Información de la aplicación',
              color: Colors.orange,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Greenhouse App',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      '© 2025 Sistema de Gestión de Invernaderos',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Aplicación para monitorear y controlar múltiples '
                      'sistemas ESP32 de invernaderos mediante WebSocket.',
                    ),
                  ],
                );
              },
            ),

            const Spacer(),

            // Información adicional
            Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
