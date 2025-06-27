import 'package:flutter/material.dart';

class PromoFilter extends StatefulWidget {
  final Function(String? name, bool? isActive) onFilterChanged;
  final VoidCallback onPressed;

  const PromoFilter({
    super.key,
    required this.onFilterChanged,
    required this.onPressed,
  });

  @override
  State<PromoFilter> createState() => _PromoFilterState();
}

class _PromoFilterState extends State<PromoFilter> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final borderColor = isDarkMode
        ? theme.colorScheme.surface
        : theme.colorScheme.onInverseSurface;
    final fillColor = isDarkMode
        ? theme.colorScheme.surface
        : theme.colorScheme.onInverseSurface;

    return Row(
      children: [
        // Campo de búsqueda
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar promociones...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.8),
              ),
            ),
            onChanged: (value) {
              widget.onFilterChanged(value, null); // Filtra por nombre
            },
          ),
        ),

        const SizedBox(width: 12),

        // Botón compacto
        ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            elevation: 3,
          ),
          child: Icon(
            Icons.add,
            size: 26,
            color: isDarkMode
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onInverseSurface,
          ),
        ),
      ],
    );
  }
}
