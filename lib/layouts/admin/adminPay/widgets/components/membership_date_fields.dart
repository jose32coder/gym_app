import 'package:flutter/material.dart';

class MembershipDateFields extends StatelessWidget {
  final TextEditingController dateRangeController;

  const MembershipDateFields({
    super.key,
    required this.dateRangeController,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 7)),
      ),
    );

    if (picked != null) {
      final String formattedRange =
          '${picked.start.day}/${picked.start.month}/${picked.start.year} - '
          '${picked.end.day}/${picked.end.month}/${picked.end.year}';
      dateRangeController.text = formattedRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: dateRangeController,
      decoration: InputDecoration(
        labelText: 'Rango de Fechas',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () => _selectDateRange(context),
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo obligatorio' : null,
    );
  }
}
