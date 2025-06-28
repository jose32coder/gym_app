import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/table_persons.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/persons/add_person.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/createCode/create_code.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// PANTALLA PRINCIPAL
class AdminPer extends StatefulWidget {
  const AdminPer({super.key});

  @override
  State<AdminPer> createState() => _AdminPerState();
}

class _AdminPerState extends State<AdminPer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          'Personas totales',
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
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: TablePersons(), // Aquí va el widget de la tabla
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'button_add_persons',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPersons(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(
          Icons.add,
          color: isDarkMode
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}

// TABLA DE PERSONAS


// ACCIONES POR PERSONA

