import 'package:flutter/material.dart';
import '../models/membership_model.dart';
import 'membership_card.dart';

class MembershipList extends StatelessWidget {
  final List<MembershipModel> memberships;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const MembershipList({
    super.key,
    required this.memberships,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (memberships.isEmpty) {
      return const Center(child: Text("No hay membresías aún"));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memberships.length,
      itemBuilder: (context, index) {
        final m = memberships[index];
        return MembershipCard(
          membership: m,
          onEdit: () => onEdit(index),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}
