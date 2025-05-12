// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:basic_flutter/components/image_selector.dart';
import 'package:basic_flutter/components/textformfield.dart';

class AddPersons extends StatelessWidget {
  final bool showMembresia;
  const AddPersons({super.key, required this.showMembresia});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: const Padding(
        //   padding: EdgeInsets.only(left: 10),
        //   child: Icon(Icons.arrow_back, size: 32),
        // ),
        title: const Text('Datos Personales'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Imageselector(),
            const SizedBox(height: 30),
            TextFormPage(showMembresia: showMembresia),
             // ahora todo con scroll si hace falta
          ],
        ),
      ),
    );
  }
}
