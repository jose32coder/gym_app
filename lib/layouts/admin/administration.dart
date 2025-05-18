import 'package:basic_flutter/layouts/admin/widgets/admin_cards.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/admin/adminReport/admin_report.dart';
import 'package:basic_flutter/layouts/admin/adminMember/admin_member.dart';
import 'package:basic_flutter/layouts/admin/adminPay/admin_pay.dart';
import 'package:basic_flutter/layouts/admin/adminPer/admin_per.dart';
import 'package:flutter/material.dart';

class Administration extends StatelessWidget {
  const Administration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración', style: TextStyles.boldText(context),),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              AdminCard(
                title: 'Personas',
                subtitle: 'Listado de personas del gimnasio',
                imagePath: 'assets/images/fondo1.jpg',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPer()));
                },
              ),
              const SizedBox(height: 10,),
              // AdminCard(
              //   title: 'Membresías',
              //   subtitle: 'Listado de membresías del gimnasio',
              //   imagePath: 'assets/images/fondo2.jpg',
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const AdminMember()));
              //   },
              // ),
              // const SizedBox(height: 10,),
              AdminCard(
                title: 'Pagos',
                subtitle: 'Administración de pagos generales',
                imagePath: 'assets/images/fondo4.jpg',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPay()));
                },
              ),
               const SizedBox(height: 10,),
              AdminCard(
                title: 'Reportes',
                subtitle: 'Listado de reportes generales',
                imagePath: 'assets/images/fondo3.jpg',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminReport()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
