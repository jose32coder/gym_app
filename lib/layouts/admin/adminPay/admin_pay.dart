import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/admin/adminPay/widgets/admin_card_pay_grid.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminPay extends StatefulWidget {
  const AdminPay({super.key});

  @override
  State<AdminPay> createState() => _AdminPayState();
}

class _AdminPayState extends State<AdminPay> {
  Widget? selectedView;

  @override
  Widget build(BuildContext context) {
    final mainColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pagos / Facturación',
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
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Administra los pagos:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildAdminCards(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (selectedView != null) ...[
                Divider(
                  thickness: 3,
                  color: mainColor,
                ),
                const SizedBox(height: 2),
                Expanded(child: selectedView!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCards() {
    return AdminCardPayGrid(
      onCardSelected: (Widget selected) {
        setState(() {
          selectedView = selected;
        });
      },
    );
  }
}
