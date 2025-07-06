import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/reportViews/report_pays.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/reportViews/report_totalperson.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminReport extends StatefulWidget {
  const AdminReport({super.key});

  @override
  _AdminReportState createState() => _AdminReportState();
}

class _AdminReportState extends State<AdminReport> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ReportTotalperson(),
    ReportPays(),
    // ReportIncome(),
  ];

  final List<String> _appBarTitles = [
    'Reporte de personas',
    // 'Reporte de Membresías',
    'Reporte de pagos',
  ];

  final List<String> _navBarLabels = [
    'Personas',
    'Pagos',
    // 'Ingresos',
  ];

  final List<IconData> _icons = [
    Icons.people,
    // Icons.card_membership,
    Icons.attach_money,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NotificationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          _appBarTitles[_selectedIndex],
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: _showNotifications,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(_icons[0]),
            label: _navBarLabels[0],
          ),
          NavigationDestination(
            icon: Icon(_icons[1]),
            label: _navBarLabels[1],
          ),
          // NavigationDestination(
          //   icon: Icon(_icons[2]),
          //   label: _navBarLabels[2],
          // ),
        ],
      ),
    );
  }
}
