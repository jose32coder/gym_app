import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/admin_mainscreen.dart';
import 'package:basic_flutter/layouts/administrator/admin/widgets/admin_cards.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/admin_report.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/admin_pay.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPer/admin_per.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Administration extends StatelessWidget {
  const Administration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administración',
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
                      MaterialPageRoute(
                          builder: (context) => const AdminPer()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              AdminCard(
                title: 'Membresías',
                subtitle: 'Listado de membresías del gimnasio',
                imagePath: 'assets/images/fondo2.jpg',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminMainScreen()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              AdminCard(
                title: 'Pagos',
                subtitle: 'Administración de pagos generales',
                imagePath: 'assets/images/fondo4.jpg',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminPay()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              AdminCard(
                title: 'Reportes',
                subtitle: 'Listado de reportes generales',
                imagePath: 'assets/images/fondo3.jpg',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminReport()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
