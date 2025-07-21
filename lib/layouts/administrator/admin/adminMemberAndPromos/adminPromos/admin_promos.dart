// ignore_for_file: unused_field

import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/adminPromos/widgets/promos_details.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/adminPromos/widgets/promos_filter.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/adminPromos/widgets/promos_form.dart';
import 'package:basic_flutter/models/model_promo.dart';
import 'package:basic_flutter/services/gimnasio_services.dart';
import 'package:basic_flutter/viewmodel/promos_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminPromos extends StatefulWidget {
  const AdminPromos({super.key});

  @override
  State<AdminPromos> createState() => _AdminPromosState();
}

class _AdminPromosState extends State<AdminPromos> {
  final PromotionViewModel _viewmodel = PromotionViewModel(GimnasioService());


  String? _filterType;
  List<PromotionModel> _cachedPromotions = [];
  bool _hasLoadedOnce = false;
  bool? _filterIsActive;

  String? uid;
  String? gimnasioId;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _fetchGimnasioId(uid!);
    }
  }

  Future<void> _fetchGimnasioId(String usuarioId) async {
    try {
      final id = await _viewmodel.gimnasioService.obtenerGimnasioId(usuarioId);

      setState(() {
        gimnasioId = id;
      });
    } catch (e) {
      print('Error al obtener gimnasioId: $e');
    }
  }

  void _navigateToForm({PromotionModel? promotionToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromosForm(
          promotionEdit: promotionToEdit,
        ),
      ),
    );
  }

  void _togglePromotionStatus(PromotionModel promo) async {
    if (uid == null) return;

    try {
      await _viewmodel.actualizarEstadoPromocion(
        usuarioId: uid!,
        promocionId: promo.id,
        nuevoEstado: !promo.isActive, // Cambia el estado actual
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            promo.isActive
                ? 'Promoción desactivada correctamente'
                : 'Promoción activada correctamente',
          ),
        ),
      );

      setState(() {}); // Refresca UI para mostrar el nuevo estado
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar promoción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
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
        child: uid == null || gimnasioId == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: [
                    // Filtro siempre visible arriba
                    PromoFilter(
                      onFilterChanged: (name, _) {
                        setState(() {
                          _searchTerm = name ?? '';
                        });
                      },
                      onPressed: _navigateToForm,
                    ),

                    const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<List<PromotionModel>>(
                        stream: _viewmodel.obtenerPromocionesPorUsuario(uid!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          // Cuando el stream esté en espera y no tengas datos, muestra loading
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !_hasLoadedOnce) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          // Actualiza la caché si hay datos nuevos
                          if (snapshot.hasData) {
                            _cachedPromotions = snapshot.data!;
                            _hasLoadedOnce = true;
                          }

                          // Usa la caché para mostrar la UI
                          List<PromotionModel> promotions = _cachedPromotions;

                          // Aplica el filtro de búsqueda
                          if (_searchTerm.isNotEmpty) {
                            promotions = promotions
                                .where((promo) => promo.name
                                    .toLowerCase()
                                    .contains(_searchTerm.toLowerCase()))
                                .toList();
                          }

                          if (promotions.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_offer_outlined,
                                      size: 64,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No hay promociones registradas',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    'con ese nombre.',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Pulsa el botón + para agregar una nueva promoción.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: promotions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 5),
                            itemBuilder: (context, index) {
                              final p = promotions[index];
                              return Card(
                                color: theme.colorScheme.surfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  leading: Icon(
                                    Icons.local_offer_outlined,
                                    color: theme.colorScheme.primary,
                                    size: 32,
                                  ),
                                  title: Text(
                                    p.name,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${p.discount.toStringAsFixed(0)}% descuento individual',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        p.isActive
                                            ? 'Activada'
                                            : 'Deshabilitada',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: p.isActive
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
                                            color: theme.colorScheme.primary),
                                        tooltip: 'Editar',
                                        onPressed: () {
                                          _navigateToForm(promotionToEdit: p);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          p.isActive
                                              ? Icons.block
                                              : Icons.check_circle,
                                          color: p.isActive
                                              ? theme.colorScheme.error
                                              : Colors.green,
                                        ),
                                        tooltip: p.isActive
                                            ? 'Deshabilitar'
                                            : 'Habilitar',
                                        onPressed: () =>
                                            _togglePromotionStatus(p),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => PromotionDetails(
                                        promotion: p,
                                        gimnasioId: gimnasioId!,
                                        promotionDocId:
                                            p.id ?? 'id_no_disponible',
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
