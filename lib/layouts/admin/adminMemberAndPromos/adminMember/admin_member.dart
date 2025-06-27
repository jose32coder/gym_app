import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/layouts/admin/adminMemberAndPromos/adminMember/widgets/membership_details.dart';
import 'package:basic_flutter/layouts/admin/adminMemberAndPromos/adminMember/widgets/membership_filter.dart';
import 'package:basic_flutter/layouts/admin/adminMemberAndPromos/adminMember/widgets/membership_form.dart';
import 'package:basic_flutter/models/model_membership.dart';
import 'package:basic_flutter/viewmodel/membership_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminMember extends StatefulWidget {
  const AdminMember({super.key});

  @override
  State<AdminMember> createState() => _AdminMemberState();
}

class _AdminMemberState extends State<AdminMember> {
  final MembershipViewmodel _viewmodel = MembershipViewmodel();

  String? _filterType;
  bool? _filterIsActive;

  String? uid;
  String? gimnasioId;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _fetchGimnasioId(uid!);
    }
  }

  void _navigateToForm({MembershipModel? membershipToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MembershipForm(
          membershipEdit: membershipToEdit,
        ),
      ),
    );
  }

  Future<void> _fetchGimnasioId(String usuarioId) async {
    try {
      final id = await _viewmodel.obtenerGimnasioId(usuarioId);
      setState(() {
        gimnasioId = id;
      });
    } catch (e) {
      print('Error al obtener gimnasioId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresías'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: uid == null || gimnasioId == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<MembershipModel>>(
                        stream: _viewmodel.obtenerMembresiasPorUsuario(uid!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          // Filtrar aquí según _filterType y _filterIsActive
                          List<MembershipModel> memberships = snapshot.data!;

                          if (_filterType != null && _filterType!.isNotEmpty) {
                            memberships = memberships
                                .where((m) => m.membershipType == _filterType)
                                .toList();
                          }

                          if (_filterIsActive != null) {
                            memberships = memberships
                                .where((m) => m.isActive == _filterIsActive)
                                .toList();
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'No hay membresías registradas para este gimnasio.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _navigateToForm();
                                    },
                                    icon: Icon(Icons.add,
                                        color: isDarkMode
                                            ? theme.colorScheme.onSurface
                                            : theme
                                                .colorScheme.onInverseSurface),
                                    label: Text(
                                      'Agregar membresía',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? theme.colorScheme.onSurface
                                            : theme
                                                .colorScheme.onInverseSurface,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              MembershipFilter(
                                onFilterChanged: (type, isActive) {
                                  setState(() {
                                    _filterType = type;
                                    _filterIsActive = isActive;
                                  });
                                },
                                onPressed: _navigateToForm,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: false,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: memberships.length,
                                  itemBuilder: (context, index) {
                                    final m = memberships[index];
                                    return Card(
                                      color: theme.colorScheme.surfaceVariant,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 6),
                                        leading: Icon(
                                          Icons.workspace_premium_outlined,
                                          color: theme.colorScheme.primary,
                                          size: 32,
                                        ),
                                        title: Text(
                                          m.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tipo: ${m.membershipType} · \$${(m.price ?? 0.0).toStringAsFixed(2)}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              m.isActive
                                                  ? 'Activada'
                                                  : 'Deshabilitada',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: m.isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined,
                                                  color: theme
                                                      .colorScheme.primary),
                                              tooltip: 'Editar',
                                              onPressed: () {
                                                _navigateToForm(
                                                    membershipToEdit: m);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                m.isActive
                                                    ? Icons.block
                                                    : Icons.check_circle,
                                                color: m.isActive
                                                    ? theme.colorScheme.error
                                                    : Colors.green,
                                              ),
                                              tooltip: m.isActive
                                                  ? 'Deshabilitar'
                                                  : 'Habilitar',
                                              onPressed: () async {
                                                try {
                                                  // Pasar gimnasioId como parámetro
                                                  await _viewmodel
                                                      .toggleMembershipActiveStatus(
                                                          m.id ??
                                                              'id_no_disponible',
                                                          m.isActive,
                                                          uid!);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(m.isActive
                                                          ? 'Membresía deshabilitada'
                                                          : 'Membresía habilitada'),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Error al actualizar el estado: $e')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                MembershipDetails(
                                              membership: m,
                                              gimnasioId: gimnasioId!,
                                              membershipDocId:
                                                  m.id ?? 'id_no_disponible',
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
