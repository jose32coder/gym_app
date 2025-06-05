import 'package:flutter/material.dart';
import '../models/membership_model.dart';

class MembershipCard extends StatelessWidget {
  final MembershipModel membership;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MembershipCard({
    super.key,
    required this.membership,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        title: Text(membership.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "Precio: \$${membership.price.toStringAsFixed(2)} - Duración: ${membership.duration}\n"
            "Descuentos: 2 pers ${membership.discount2}% | 3 pers ${membership.discount3}% | 4 pers ${membership.discount4}%"),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
