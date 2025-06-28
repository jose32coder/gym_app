import 'package:flutter/material.dart';

class FilterReport extends StatelessWidget {
  final List<String> periodos;
  final String selectedPeriodo;
  final ValueChanged<String?> onPeriodoChanged;
  final VoidCallback onGeneratePDF;
  final VoidCallback onGenerateExcel;

  const FilterReport({
    Key? key,
    required this.periodos,
    required this.selectedPeriodo,
    required this.onPeriodoChanged,
    required this.onGeneratePDF,
    required this.onGenerateExcel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double buttonPaddingHorizontal = 14;
    const double buttonPaddingVertical = 14;
    const double iconSize = 20;

    return Row(
      children: [
        // Dropdown de período
        Flexible(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                icon: Icon(Icons.calendar_today,
                    color: theme.colorScheme.primary),
                value: selectedPeriodo,
                items: periodos
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: onPeriodoChanged,
                dropdownColor: theme.cardColor,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Botón PDF
        _ExportButton(
          label: 'PDF',
          icon: Icons.picture_as_pdf,
          iconColor: Colors.redAccent,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          paddingHorizontal: buttonPaddingHorizontal,
          paddingVertical: buttonPaddingVertical,
          iconSize: iconSize,
          tooltip: 'Generar reporte en PDF',
          onPressed: onGeneratePDF,
        ),

        const SizedBox(width: 12),

        // Botón Excel
        _ExportButton(
          label: 'Excel',
          icon: Icons.file_copy,
          iconColor: Colors.lightGreen,
          backgroundColor: Colors.lightGreen.withOpacity(0.1),
          paddingHorizontal: buttonPaddingHorizontal,
          paddingVertical: buttonPaddingVertical,
          iconSize: iconSize,
          tooltip: 'Generar reporte en Excel',
          onPressed: onGenerateExcel,
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double paddingHorizontal;
  final double paddingVertical;
  final double iconSize;
  final String tooltip;
  final VoidCallback onPressed;

  const _ExportButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.iconSize,
    required this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal, vertical: paddingVertical),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, size: iconSize, color: iconColor),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
