import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/table_persons.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/persons/add_person.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AddPersons(showMembresia: false)));
        },
        icon: const Icon(Icons.add),
        label: const Text("Agregar Persona"),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey.shade300 // Color en modo oscuro
            : Colors.lightBlue.shade700, // Color en modo claro
        foregroundColor: Colors.white, // Color del texto (blanco)
      ),
    );
  }
}

// TABLA DE PERSONAS


// ACCIONES POR PERSONA

