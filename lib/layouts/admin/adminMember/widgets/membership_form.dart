import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MembershipForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController discount2Controller;
  final TextEditingController discount3Controller;
  final TextEditingController discount4Controller;
  final String selectedDuration;
  final List<String> durations;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final ValueChanged<String?> onDurationChanged;
  final bool isEditing;

  const MembershipForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.priceController,
    required this.discount2Controller,
    required this.discount3Controller,
    required this.discount4Controller,
    required this.selectedDuration,
    required this.durations,
    required this.onSave,
    this.onCancel,
    required this.onDurationChanged,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                isEditing ? "Editar Membresía" : "Nueva Membresía",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: "Nombre de la membresía"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Precio base"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Requerido";
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return "Debe ser un número positivo";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedDuration,
                items: durations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: onDurationChanged,
                decoration: const InputDecoration(labelText: "Duración"),
              ),
              const SizedBox(height: 12),
             
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onSave,
                        icon: isEditing
                            ? FaIcon(FontAwesomeIcons.refresh,
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface)
                            : FaIcon(FontAwesomeIcons.save,
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface),
                        label: Text(
                          isEditing ? "Actualizar" : "Guardar",
                          style: TextStyle(
                              color: isDarkMode
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onInverseSurface),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isEditing)
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: onSave,
                          icon: FaIcon(FontAwesomeIcons.cancel, color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface),
                          label: Text('Cancelar',
                            style: TextStyle(
                                color: isDarkMode
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onInverseSurface),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
