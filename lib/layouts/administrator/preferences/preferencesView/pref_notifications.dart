import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrefNotifications extends StatefulWidget {
  const PrefNotifications({super.key});

  @override
  State<PrefNotifications> createState() => _PrefNotificationsState();
}

class _PrefNotificationsState extends State<PrefNotifications> {
  // Estados de los switches
  bool _membershipNotif = true;
  bool _paymentNotif = true;
  bool _personRegNotif = false;
  bool _reportNotif = true;
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  String _selectedSound = 'Tono clásico';

  final List<String> _soundOptions = [
    'Tono clásico',
    'Campana suave',
    'Alerta digital',
    'Silencio'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Notificaciones',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const NotificationModal(),
                );
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Preferencias de notificación',
              style: TextStyles.boldText(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
        
            // Categoría: Tipos de notificación
            ExpansionTile(
              title: Text(
                'Tipos de notificación',
                style: TextStyles.boldText(context),
              ),
              leading: const Icon(Icons.notifications_active),
              children: [
                SwitchListTile(
                  title: const Text('Membresías nuevas'),
                  subtitle: const Text('Recibe alertas cuando se registre una membresía'),
                  value: _membershipNotif,
                  onChanged: (value) {
                    setState(() {
                      _membershipNotif = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Pagos recibidos'),
                  subtitle: const Text('Se te notificará cada vez que se registre un pago'),
                  value: _paymentNotif,
                  onChanged: (value) {
                    setState(() {
                      _paymentNotif = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Registro de personas'),
                  subtitle: const Text('Notificación al registrar una persona nueva'),
                  value: _personRegNotif,
                  onChanged: (value) {
                    setState(() {
                      _personRegNotif = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Reportes disponibles'),
                  subtitle: const Text('Recibe aviso cuando haya reportes nuevos'),
                  value: _reportNotif,
                  onChanged: (value) {
                    setState(() {
                      _reportNotif = value;
                    });
                  },
                ),
              ],
            ),
        
            const SizedBox(height: 24),
        
            // Categoría: Canal de notificación
            ExpansionTile(
              title: Text(
                'Canal de notificación',
                style: TextStyles.boldText(context),
              ),
              leading: const Icon(Icons.settings_applications),
              children: [
                SwitchListTile(
                  title: const Text('Notificaciones Push'),
                  subtitle: const Text('Activa o desactiva notificaciones en tiempo real'),
                  value: _pushEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Notificaciones por email'),
                  subtitle: const Text('Recibe alertas en tu correo electrónico'),
                  value: _emailEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailEnabled = value;
                    });
                  },
                ),
              ],
            ),
        
            const SizedBox(height: 24),
        
            // Nueva Categoría: Preferencias adicionales
            ExpansionTile(
              title: Text(
                'Preferencias de notificación',
                style: TextStyles.boldText(context),
              ),
              leading: const Icon(Icons.tune),
              children: [
                SwitchListTile(
                  title: const Text('Vibración'),
                  subtitle: const Text('Habilita la vibración al recibir una notificación'),
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Sonido'),
                  subtitle: const Text('Activa sonido al recibir notificaciones'),
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                if (_soundEnabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tono de notificación',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSound,
                      items: _soundOptions.map((tone) {
                        return DropdownMenuItem(
                          value: tone,
                          child: Text(tone),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSound = value;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
        
            const SizedBox(height: 32),
        
            // Botón guardar
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferencias guardadas')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar preferencias'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
