import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/greenhouse_detail_provider.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        final enabled = provider.isConnected;
        final status = provider.currentStatus;

        return Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel de Control',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Controles del Servo
                const Text(
                  'Servo Motor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            (enabled && (status?.servo.canRotateLeft ?? true))
                            ? provider.servoLeft
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Izquierda'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            (enabled && (status?.servo.canRotateRight ?? true))
                            ? provider.servoRight
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Derecha'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Controles de LEDs
                const Text(
                  'LEDs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: enabled ? provider.ledsOn : null,
                        icon: const Icon(Icons.lightbulb),
                        label: const Text('Encender'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.amber.shade600, // más contrastante
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary, // se adapta
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: enabled ? provider.ledsOff : null,
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Apagar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enabled ? provider.ledsToggle : null,
                    icon: const Icon(Icons.sync),
                    label: const Text('Alternar LEDs'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Leer Sensor
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enabled ? provider.readSensor : null,
                    icon: const Icon(Icons.sensors),
                    label: const Text('Leer Sensor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
