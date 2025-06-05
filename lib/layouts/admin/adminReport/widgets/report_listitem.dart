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
      child: InkWell(
        onTap:
            onViewMore, 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const Icon(
                  Icons.arrow_forward_ios), // icono flecha pequeña a la derecha
            ],
          ),
        ),
      ),
    );
  }
}
