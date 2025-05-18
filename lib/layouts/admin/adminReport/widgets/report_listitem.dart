import 'package:flutter/material.dart';

class ReportListItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onViewMore;

  const ReportListItem({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Ver más'),
                onPressed: onViewMore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
