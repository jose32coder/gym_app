import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class MembershipFilter extends StatefulWidget {
  final Function(String?, bool?) onFilterChanged;
  final VoidCallback onPressed;

  const MembershipFilter(
      {super.key, required this.onFilterChanged, required this.onPressed});

  @override
  State<MembershipFilter> createState() => _MembershipFilterState();
}

class _MembershipFilterState extends State<MembershipFilter> {
  String? selectedType;
  bool? isActiveStatus;

  void _clearFilters() {
    if (selectedType != null || isActiveStatus != null) {
      setState(() {
        selectedType = null;
        isActiveStatus = null;
      });
      widget.onFilterChanged(selectedType, isActiveStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tipo de membresía', style: TextStyles.boldText(context)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.assignment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todas')),
                DropdownMenuItem(value: 'Diario', child: Text('Diario')),
                DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                DropdownMenuItem(value: 'Quincenal', child: Text('Quincenal')),
                DropdownMenuItem(value: 'Mensual', child: Text('Mensual')),
                DropdownMenuItem(
                    value: 'Trimestral', child: Text('Trimestral')),
                DropdownMenuItem(value: 'Semestral', child: Text('Semestral')),
                DropdownMenuItem(value: 'Anual', child: Text('Anual')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
                widget.onFilterChanged(selectedType, isActiveStatus);
              },
            ),
            const SizedBox(height: 6),
            Text('Estado', style: TextStyles.boldText(context)),
            const SizedBox(height: 5),
            DropdownButtonFormField<bool>(
              value: isActiveStatus,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.toggle_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: true, child: Text('Activas')),
                DropdownMenuItem(value: false, child: Text('Deshabilitadas')),
              ],
              onChanged: (value) {
                setState(() {
                  isActiveStatus = value;
                });
                widget.onFilterChanged(selectedType, isActiveStatus);
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onInverseSurface,
                    ),
                    label: Text(
                      'Limpiar filtro',
                      style: TextStyle(
                        color: isDarkMode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 50,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
