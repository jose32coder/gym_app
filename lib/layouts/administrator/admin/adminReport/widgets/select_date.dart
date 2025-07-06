import 'package:flutter/material.dart';

class DateRangeFilter extends StatefulWidget {
  final void Function(DateTimeRange?) onDateRangeChanged;

  const DateRangeFilter({super.key, required this.onDateRangeChanged});

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  DateTimeRange? _selectedDateRange;

  String get _dateRangeLabel {
    if (_selectedDateRange == null) return 'Filtrar datos por fecha';
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      widget.onDateRangeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectDateRange,
            icon: Icon(Icons.date_range, color: theme.colorScheme.onSurface),
            label: Text(
              _dateRangeLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.09),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        if (_selectedDateRange != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.clear, color: theme.colorScheme.error),
            onPressed: () {
              setState(() {
                _selectedDateRange = null;
              });
              widget.onDateRangeChanged(null);
            },
            tooltip: 'Limpiar filtro de fecha',
          ),
        ],
      ],
    );
  }
}
