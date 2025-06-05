import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/admin/adminReport/reportViews/report_income.dart';
import 'package:basic_flutter/layouts/admin/adminReport/reportViews/report_membership.dart';
import 'package:basic_flutter/layouts/admin/adminReport/reportViews/report_totalperson.dart';
import 'package:basic_flutter/layouts/admin/adminReport/widgets/report_listitem.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminReport extends StatelessWidget {
  const AdminReport({super.key});

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
          'Reporte general',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReportListItem(
            title: 'Total de personas',
            description: 'Número total de personas registradas',
            icon: Icons.people,
            color: Colors.blue,
            onViewMore: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportTotalperson()),
              );
            },
          ),
          ReportListItem(
            title: 'Membresías vigentes',
            description: 'Cantidad de membresías activas en el sistema',
            icon: Icons.card_membership,
            color: Colors.indigo,
            onViewMore: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportMembership()),
              );
            },
          ),
          ReportListItem(
            title: 'Ingresos por periodo',
            description: 'Resumen de ingresos por día, semana, mes o año',
            icon: Icons.attach_money,
            color: Colors.teal,
            onViewMore: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIncome()),
              );
            },
          ),
        ],
      ),
    );
  }
}
