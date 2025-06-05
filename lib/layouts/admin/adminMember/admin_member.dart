import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/admin/adminMember/models/membership_model.dart';
import 'package:basic_flutter/layouts/admin/adminMember/widgets/membership_form.dart';
import 'package:basic_flutter/layouts/admin/adminMember/widgets/membership_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminMember extends StatefulWidget {
  const AdminMember({super.key});

  @override
  State<AdminMember> createState() => _AdminMemberState();
}

class _AdminMemberState extends State<AdminMember> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discount2Controller = TextEditingController(text: "5");
  final _discount3Controller = TextEditingController(text: "10");
  final _discount4Controller = TextEditingController(text: "20");

  String _selectedDuration = "Mensual";
  final List<String> _durations = [
    "Diario",
    "Semanal",
    "Quincenal",
    "Mensual",
    "Trimestral",
    "Semestral",
    "Anual",
  ];

  final List<MembershipModel> _memberships = [];
  int? _editingIndex;

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _priceController.clear();
    _discount2Controller.text = "5";
    _discount3Controller.text = "10";
    _discount4Controller.text = "20";
    _selectedDuration = "Mensual";
    _editingIndex = null;
    setState(() {});
  }

  void _saveMembership() {
    if (!_formKey.currentState!.validate()) return;
    final newMembership = MembershipModel(
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      duration: _selectedDuration,
      discount2: double.parse(_discount2Controller.text.trim()),
      discount3: double.parse(_discount3Controller.text.trim()),
      discount4: double.parse(_discount4Controller.text.trim()),
    );

    setState(() {
      if (_editingIndex == null) {
        _memberships.add(newMembership);
      } else {
        _memberships[_editingIndex!] = newMembership;
      }
    });
    _resetForm();
  }

  void _editMembership(int index) {
    final m = _memberships[index];
    _nameController.text = m.name;
    _priceController.text = m.price.toStringAsFixed(2);
    _discount2Controller.text = m.discount2.toStringAsFixed(2);
    _discount3Controller.text = m.discount3.toStringAsFixed(2);
    _discount4Controller.text = m.discount4.toStringAsFixed(2);
    _selectedDuration = m.duration;
    _editingIndex = index;
    setState(() {});
  }

  void _deleteMembership(int index) {
    setState(() {
      _memberships.removeAt(index);
      if (_editingIndex == index) _resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gestión de Membresías",
          style: TextStyles.boldPrimaryText(context),
        ),
        centerTitle: true,
       actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const NotificationModal(),
                );
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            MembershipForm(
              formKey: _formKey,
              nameController: _nameController,
              priceController: _priceController,
              discount2Controller: _discount2Controller,
              discount3Controller: _discount3Controller,
              discount4Controller: _discount4Controller,
              selectedDuration: _selectedDuration,
              durations: _durations,
              onSave: _saveMembership,
              onCancel: _resetForm,
              onDurationChanged: (v) {
                if (v != null) setState(() => _selectedDuration = v);
              },
              isEditing: _editingIndex != null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Text(
                "Membresías guardadas (${_memberships.length})",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            MembershipList(
              memberships: _memberships,
              onEdit: _editMembership,
              onDelete: _deleteMembership,
            )
          ],
        ),
      ),
    );
  }
}
