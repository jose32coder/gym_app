// ignore_for_file: camel_case_types
import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';
import 'package:basic_flutter/layouts/persons/widgets/image_selector.dart';
import 'package:basic_flutter/layouts/persons/widgets/textformfield.dart';

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
        title: Text('Datos Personales', style: TextStyles.boldText(context),),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Imageselector(),
              const SizedBox(height: 30),
              TextFormPage(),
               // ahora todo con scroll si hace falta
            ],
          ),
        ),
      ),
    );
  }
}
