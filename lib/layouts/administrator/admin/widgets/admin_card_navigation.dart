import 'package:basic_flutter/layouts/administrator/admin/widgets/admin_cards.dart';
import 'package:flutter/material.dart';

class AdminCardNavigation extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final WidgetBuilder destinationBuilder;

  const AdminCardNavigation({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.destinationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: destinationBuilder),
        );
      },
    );
  }
}
