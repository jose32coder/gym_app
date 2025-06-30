import 'package:flutter/material.dart';

class EdadSelector extends StatefulWidget {
  final int minEdad;
  final int maxEdad;
  final ValueChanged<int> onEdadChanged;
  final int edadInicial;

  const EdadSelector({
    super.key,
    required this.minEdad,
    required this.maxEdad,
    required this.onEdadChanged,
    required this.edadInicial,
  });

  @override
  State<EdadSelector> createState() => _EdadSelectorState();
}

class _EdadSelectorState extends State<EdadSelector> {
  late FixedExtentScrollController _controller;
  late int edadSeleccionada;

  @override
  void initState() {
    super.initState();
    edadSeleccionada = widget.edadInicial;
    _controller = FixedExtentScrollController(
      initialItem: edadSeleccionada - widget.minEdad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems = widget.maxEdad - widget.minEdad + 1;

    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        physics: const FixedExtentScrollPhysics(),
        itemExtent: 50,
        onSelectedItemChanged: (index) {
          final edad = widget.minEdad + index;
          setState(() {
            edadSeleccionada = edad;
          });
          widget.onEdadChanged(edad);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index >= totalItems) return null;
            final edad = widget.minEdad + index;
            final isSelected = edad == edadSeleccionada;

            return Center(
              child: Transform.scale(
                scale: isSelected
                    ? 1.8
                    : 1.0, // escala para agrandar el seleccionado
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.surface,
                        width: isSelected ? 1 : 0,
                      ),
                      top: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.surface,
                        width: isSelected ? 1 : 0,
                      ),
                    ),
                  ),
                  child: Text(
                    '$edad',
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 20,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: totalItems,
        ),
      ),
    );
  }
}
