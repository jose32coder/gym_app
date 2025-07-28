import 'package:basic_flutter/components/animations.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/admin_pay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Components
import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';

// Layouts & Widgets
import 'package:basic_flutter/layouts/administrator/admin/adminPer/admin_per.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/widgets/person_details_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/payViews/widgets/history_operations.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/bubble_client.dart';
import 'package:basic_flutter/layouts/administrator/home/widgets/resume_cards.dart';

// ViewModels
import 'package:basic_flutter/viewmodel/pay_viewmodel.dart';
import 'package:basic_flutter/viewmodel/person_viewmodel.dart';

class Home extends StatefulWidget {
  final bool isActive;

  final String? nombreUsuario;
  const Home({super.key, this.nombreUsuario, this.isActive = false});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late Animation<double> _fadeAnimationMovimientos;
  late Animation<Offset> _slideAnimationMovimientos;

  late Animation<double> _fadeAnimation2;
  late Animation<Offset> _slideAnimation2;

  // Para animaciones del AppBar:
  late Animation<double> _fadeTitle;
  late Animation<Offset> _slideTitle;

  late Animation<double> _fadeIcon;
  late Animation<Offset> _slideIcon;

  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Tus animaciones originales
    _fadeAnimation =
        CustomAnimations.fadeAnimation(_controller, start: 0.0, finish: 1.0);
    _slideAnimation =
        CustomAnimations.slideAnimation(_controller, start: 0.0, finish: 1.0);

    _fadeAnimationMovimientos = CustomAnimations.fadeAnimationMovimientos(
        _controller,
        start: 0.0,
        finish: 1.0);
    _slideAnimationMovimientos = CustomAnimations.slideAnimationMovimientos(
        _controller,
        start: 0.3,
        finish: 1.0);

    _fadeAnimation2 =
        CustomAnimations.fadeAnimation2(_controller, start: 0.0, finish: 1.0);
    _slideAnimation2 =
        CustomAnimations.slideAnimation2(_controller, start: 0.3, finish: 1.0);

    // Animaciones AppBar
    _fadeTitle = CustomAnimations.fadeIn(_controller, start: 0.0, finish: 0.5);
    _slideTitle =
        CustomAnimations.slideFromLeft(_controller, start: 0.0, finish: 0.5);

    _fadeIcon = CustomAnimations.fadeIn(_controller, start: 0.0, finish: 0.5);
    _slideIcon =
        CustomAnimations.slideFromRight(_controller, start: 0.0, finish: 0.5);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _loadDataOnce(context);
      _dataLoaded = true;
    }

    if (widget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  void _loadDataOnce(BuildContext context) {
    if (_dataLoaded) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payVM = context.read<PayViewModel>();
      final personasVM = context.read<PersonasViewModel>();

      if (payVM.payments.isEmpty) {
        payVM.cargarGimnasioId();
      }

      if (personasVM.usuarios.isEmpty) {
        personasVM.cargarUsuarios();
      }
    });

    _dataLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final payVM = context.watch<PayViewModel>();
    final personasVM = context.watch<PersonasViewModel>();

    final isLoading = payVM.isLoading || personasVM.isLoading;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: FadeTransition(
              opacity: _fadeTitle,
              child: SlideTransition(
                position: _slideTitle,
                child: Text(
                  'Hola, ${widget.nombreUsuario ?? 'Usuario'} 👋',
                  style: TextStyles.boldPrimaryText(context),
                ),
              ),
            ),
            actions: [
              FadeTransition(
                opacity: _fadeIcon,
                child: SlideTransition(
                  position: _slideIcon,
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
                        builder: (_) => const NotificationModal(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildUltimosClientes(
                              personasVM, context, isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimationMovimientos,
                        child: SlideTransition(
                          position: _slideAnimationMovimientos,
                          child: _buildResumenUsuarios(personasVM, context),
                        ),
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation2,
                        child: SlideTransition(
                            position: _slideAnimation2,
                            child: _buildUltimosMovimientos(payVM, context)),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

Widget _buildUltimosMovimientos(PayViewModel payVM, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Últimos movimientos', style: TextStyles.boldText(context)),
          TextButton(
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminPay(initialIndex: 2)),
                );
              });
            },
            child: const Text('Ver todos'),
          ),
        ],
      ),
      const SizedBox(height: 10),
      HistoryOperations(payments: payVM.payments),
    ],
  );
}

Widget _buildUltimosClientes(
    PersonasViewModel personasVM, BuildContext context, bool isDarkMode) {
  final ultimosClientes = personasVM.ultimosClientes;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Últimos clientes registrados',
              style: TextStyles.boldText(context)),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminPer()),
            ),
            child: const Text('Ver todos'),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (ultimosClientes.isNotEmpty)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ultimosClientes.map((cliente) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BubbleClient(
                  cliente: cliente,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => PersonDetailsModal(
                        persona: cliente,
                        onClose: () => Navigator.of(context).pop(),
                        isDarkMode: isDarkMode,
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        )
      else
        const Text('No hay clientes registrados aún.'),
    ],
  );
}

Widget _buildResumenUsuarios(
    PersonasViewModel personasVM, BuildContext context) {
  final usuarios = personasVM.usuarios;
  final activos = usuarios
      .where((u) => (u['estado'] ?? '').toLowerCase() == 'activo')
      .toList();
  final pendientes = usuarios
      .where((u) => (u['estado'] ?? '').toLowerCase() == 'pendiente')
      .toList();
  final inactivos = usuarios
      .where((u) => (u['estado'] ?? '').toLowerCase() == 'inactivo')
      .toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Estado de usuarios', style: TextStyles.boldText(context)),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ResumeCards(
              title: 'Total personas',
              value: usuarios.length.toString(),
              icon: Icons.people,
              color: Colors.blue),
          ResumeCards(
              title: 'Activos',
              value: activos.length.toString(),
              icon: Icons.person,
              color: Colors.green),
          ResumeCards(
              title: 'Pendientes',
              value: pendientes.length.toString(),
              icon: Icons.warning,
              color: Colors.yellow),
          ResumeCards(
              title: 'Inactivos',
              value: inactivos.length.toString(),
              icon: Icons.warning,
              color: Colors.red),
        ],
      ),
    ],
  );
}
