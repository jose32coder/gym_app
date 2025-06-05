import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/gymCodeOrSelect/code_activation.dart';
import 'package:basic_flutter/gymCodeOrSelect/select_gym.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SelectionRolPage extends StatelessWidget {
  const SelectionRolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Elige tu rol',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              '¿Cómo deseas ingresar?',
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona una de las siguientes opciones para continuar:',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Opción: Dueño de Gimnasio
            _buildOptionCard(
              context,
              icon: FontAwesomeIcons.dumbbell,
              title: 'Dueño de gimnasio',
              colorText: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
              color: theme.colorScheme.secondary,
              iconColor: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CodeActivation()),
                );
              },
            ),
            const SizedBox(height: 25),

            // Opción: Cliente
            _buildOptionCard(
              context,
              icon: FontAwesomeIcons.user,
              title: 'Administrador de gimnasio',
              colorText: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
              color: theme.colorScheme.secondary,
              iconColor: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectGym()),
                );
              },
            ),
            const SizedBox(height: 25),
             _buildOptionCard(
              context,
              icon: FontAwesomeIcons.dumbbell,
              title: 'Cliente de gimnasio',
              colorText: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
              color: theme.colorScheme.secondary,
              iconColor: isDarkMode
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onInverseSurface,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectGym()),
                );
              },
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required Color colorText,
      required Color iconColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 40,
                color: iconColor,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w600, color: colorText),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 20, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
