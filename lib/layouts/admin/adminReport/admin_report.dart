import 'package:basic_flutter/layouts/admin/adminReport/reportViews/report_income.dart';
import 'package:basic_flutter/layouts/admin/adminReport/reportViews/report_membership.dart';
import 'package:basic_flutter/layouts/admin/adminReport/reportViews/report_totalperson.dart';
import 'package:basic_flutter/layouts/admin/adminReport/widgets/report_listitem.dart';
import 'package:flutter/material.dart';

class AdminReport extends StatelessWidget {
  const AdminReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte General'),
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
