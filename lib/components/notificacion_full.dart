import 'package:flutter/material.dart';

class NotificacionFull extends StatelessWidget {
  const NotificacionFull({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allNotifications =
        List.generate(20, (index) {
      return {
        'title': 'Notificación #$index',
        'body': 'Contenido de la notificación número $index.',
        'date': DateTime.now().subtract(Duration(hours: index * 2)),
      };
    });

    return Scaffold(
        appBar: AppBar(
          title: const Text('Todas las notificaciones'),
          centerTitle: true,
        ),
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: allNotifications.length,
          itemBuilder: (context, index) {
            final notif = allNotifications[index];
            return Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(notif['title']),
                  subtitle: Text(notif['body']),
                  trailing: Text(
                    _formatDate(notif['date']),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const Divider(),
              ],
            );
          },
        ));
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
