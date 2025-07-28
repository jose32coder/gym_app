import 'package:basic_flutter/components/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminMemberAndPromos/admin_mainscreen.dart';
import 'package:basic_flutter/layouts/administrator/admin/widgets/admin_card_navigation.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminReport/admin_report.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPay/admin_pay.dart';
import 'package:basic_flutter/layouts/administrator/admin/adminPer/admin_per.dart';
import 'package:basic_flutter/components/route_observer.dart';

class Administration extends StatefulWidget {
  final bool isActive;

  const Administration({super.key, this.isActive = false});

  @override
  State<Administration> createState() => _AdministrationState();
}

class _AdministrationState extends State<Administration>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  late Animation<double> _fadeTitle;
  late Animation<Offset> _slideTitle;

  late Animation<double> _fadeIcon;
  late Animation<Offset> _slideIcon;

  bool _imagesPrecached = false;
  late Future<void> _precacheImagesFuture;

  final AssetImage fondo1 = const AssetImage('assets/images/fondo1.webp');
  final AssetImage fondo2 = const AssetImage('assets/images/fondo2.webp');
  final AssetImage fondo3 = const AssetImage('assets/images/fondo3.webp');
  final AssetImage fondo4 = const AssetImage('assets/images/fondo4.webp');

  final int _itemCount = 4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimations =
        CustomAnimations.generateSlideAnimations(_controller, _itemCount);
    _fadeAnimations =
        CustomAnimations.generateFadeAnimations(_controller, _itemCount);

    _fadeTitle = CustomAnimations.fadeIn(_controller, start: 0.0, finish: 0.5);
    _slideTitle =
        CustomAnimations.slideFromLeft(_controller, start: 0.0, finish: 0.5);
    _fadeIcon = CustomAnimations.fadeIn(_controller, start: 0.0, finish: 0.5);
    _slideIcon =
        CustomAnimations.slideFromRight(_controller, start: 0.0, finish: 0.5);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    if (!_imagesPrecached) {
      _precacheImagesFuture = _precacheAllImages();
      _imagesPrecached = true;
    }
  }

  Future<void> _precacheAllImages() async {
    await Future.wait([
      precacheImage(fondo1, context),
      precacheImage(fondo2, context),
      precacheImage(fondo3, context),
      precacheImage(fondo4, context),
    ]);
  }

  @override
  void didUpdateWidget(covariant Administration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  Widget _buildAnimatedCard({required Widget child, required int index}) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildAnimatedCard(
              index: 0,
              child: AdminCardNavigation(
                title: 'Personas',
                subtitle: 'Listado de personas del gimnasio',
                imagePath: 'assets/images/fondo1.webp',
                destinationBuilder: (context) => const AdminPer(),
              ),
            ),
            const SizedBox(height: 10),
            _buildAnimatedCard(
              index: 1,
              child: AdminCardNavigation(
                title: 'Membresías',
                subtitle: 'Listado de membresías del gimnasio',
                imagePath: 'assets/images/fondo2.webp',
                destinationBuilder: (context) => const AdminMainScreen(),
              ),
            ),
            const SizedBox(height: 10),
            _buildAnimatedCard(
              index: 2,
              child: AdminCardNavigation(
                title: 'Pagos',
                subtitle: 'Administración de pagos generales',
                imagePath: 'assets/images/fondo4.webp',
                destinationBuilder: (context) => const AdminPay(),
              ),
            ),
            const SizedBox(height: 10),
            _buildAnimatedCard(
              index: 3,
              child: AdminCardNavigation(
                title: 'Reportes',
                subtitle: 'Listado de reportes generales',
                imagePath: 'assets/images/fondo3.webp',
                destinationBuilder: (context) => const AdminReport(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _precacheImagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (widget.isActive) _controller.forward(from: 0);
          return Scaffold(
            appBar: AppBar(
              title: FadeTransition(
                opacity: _fadeTitle,
                child: SlideTransition(
                  position: _slideTitle,
                  child: Text(
                    'Administración',
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
                const SizedBox(width: 10),
              ],
            ),
            body: _buildContent(),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
