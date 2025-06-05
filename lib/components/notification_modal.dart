import 'package:basic_flutter/components/notificacion_full.dart';
import 'package:flutter/material.dart';

class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Nuevo pago recibido',
        'body': 'Se ha registrado un pago por \$50.',
        'date': DateTime.now().subtract(const Duration(minutes: 10)),
      },
      {
        'title': 'Membresía activada',
        'body': 'La membresía de Pedro Pérez está activa.',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'title': 'Reporte generado',
        'body': 'Nuevo reporte mensual disponible.',
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'title': 'Nuevo registro',
        'body': 'María López ha sido registrada.',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'title': 'Alerta de sistema',
        'body': 'Se detectó una anomalía en la base de datos.',
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'Notificaciones recientes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active, color: Colors.blue),
                    title: Text(notif['title']),
                    subtitle: Text(notif['body']),
                    trailing: Text(
                      _formatDate(notif['date']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      // Opcional: navegar o mostrar detalle
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificacionFull()),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ver más notificaciones'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} h';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else {
      return '${diff.inDays} días';
    }
  }
}
