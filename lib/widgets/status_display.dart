import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/greenhouse_detail_provider.dart';

class StatusDisplay extends StatelessWidget {
  const StatusDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GreenhouseDetailProvider>(
      builder: (context, provider, child) {
        final status = provider.currentStatus;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado del Sistema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (status == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Sin información de estado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else ...[
                  _StatusRow(
                    icon: Icons.settings_remote,
                    label: 'Servo',
                    value: status.servo.state.toUpperCase(),
                  ),
                  const Divider(height: 24),
                  _StatusRow(
                    icon: Icons.arrow_back,
                    label: 'Puede girar izquierda',
                    value: status.servo.canRotateLeft ? 'Sí' : 'No',
                    valueColor: status.servo.canRotateLeft
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    icon: Icons.arrow_forward,
                    label: 'Puede girar derecha',
                    value: status.servo.canRotateRight ? 'Sí' : 'No',
                    valueColor: status.servo.canRotateRight
                        ? Colors.green
                        : Colors.red,
                  ),
                  const Divider(height: 24),
                  _StatusRow(
                    icon: Icons.lightbulb,
                    label: 'LEDs',
                    value: status.leds.on ? 'ENCENDIDOS' : 'APAGADOS',
                    valueColor: status.leds.on ? Colors.amber : Colors.grey,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
