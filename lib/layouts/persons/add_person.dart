// ignore_for_file: camel_case_types
import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/layouts/persons/widgets/image_selector.dart';
import 'package:basic_flutter/layouts/persons/widgets/textformfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddPersons extends StatelessWidget {
  final bool showMembresia;
  const AddPersons({super.key, required this.showMembresia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Datos Personales',
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: false,
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
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Imageselector(),
              SizedBox(height: 30),
              TextFormPage(),
            ],
          ),
        ),
      ),
    );
  }
}
