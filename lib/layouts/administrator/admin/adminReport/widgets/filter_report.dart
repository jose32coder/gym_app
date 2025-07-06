import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/select_date.dart';
import 'package:flutter/material.dart';

class FilterReport extends StatelessWidget {
  final VoidCallback onGeneratePDF;
  final VoidCallback onGenerateExcel;
  final void Function(DateTimeRange?)? onDateRangeChanged;
  final List<String>? membresias;
  final String? selectedMembresia;
  final ValueChanged<String?>? onMembresiaChanged;

  const FilterReport({
    super.key,
    required this.onGeneratePDF,
    required this.onGenerateExcel,
    this.onDateRangeChanged,
    this.membresias,
    this.selectedMembresia,
    this.onMembresiaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    const double iconSize = 20;
    final bool showMembresiaFilter =
        membresias != null && onMembresiaChanged != null;

    return Column(
      children: [
        // Filtro por rango de fecha (opcional)
        if (onDateRangeChanged != null)
          DateRangeFilter(onDateRangeChanged: onDateRangeChanged!),

        if (onDateRangeChanged != null) const SizedBox(height: 8),

        Row(
          children: [
            // Dropdown Membresía (opcional)
            if (showMembresiaFilter)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMembresia ?? 'Todas',
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down,
                          color: theme.colorScheme.onSurface),
                      dropdownColor: theme.colorScheme.surface,
                      items: ['Todas', 'Sin membresía', ...membresias!]
                          .map((membresia) => DropdownMenuItem(
                                value: membresia,
                                child: Text(
                                  membresia,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: onMembresiaChanged,
                    ),
                  ),
                ),
              ),

            if (showMembresiaFilter) const SizedBox(width: 12),

            // Botón PDF
            showMembresiaFilter
                ? _IconButton(
                    icon: Icons.picture_as_pdf,
                    iconColor: Colors.red,
                    backgroundColor: Colors.redAccent.withOpacity(0.3),
                    iconSize: iconSize,
                    tooltip: 'Generar reporte en PDF',
                    onPressed: onGeneratePDF,
                  )
                : Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.redAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onGeneratePDF,
                      icon: Icon(Icons.picture_as_pdf,
                          size: iconSize,
                          color: isDarkMode ? Colors.redAccent : Colors.red),
                      label: Text(
                        'Exportar PDF',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),

            const SizedBox(width: 12),

            // Botón Excel
            showMembresiaFilter
                ? _IconButton(
                    icon: Icons.file_copy,
                    iconColor: Colors.green,
                    backgroundColor: Colors.lightGreen.withOpacity(0.3),
                    iconSize: iconSize,
                    tooltip: 'Generar reporte en Excel',
                    onPressed: onGenerateExcel,
                  )
                : Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.lightGreen.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onGenerateExcel,
                      icon: Icon(Icons.file_copy,
                          size: iconSize,
                          color:
                              isDarkMode ? Colors.greenAccent : Colors.green),
                      label: Text(
                        'Exportar Excel',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double iconSize;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.iconSize,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
