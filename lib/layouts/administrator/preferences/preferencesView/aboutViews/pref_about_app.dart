import 'package:basic_flutter/components/notification_modal.dart';
import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/aboutViews/widgets/app_logo_section.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/aboutViews/widgets/contact_info_tile.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/aboutViews/widgets/feedback_button.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/aboutViews/widgets/legal_links.dart';
import 'package:basic_flutter/layouts/administrator/preferences/preferencesView/aboutViews/widgets/social_button_row.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrefAboutApp extends StatelessWidget {
  const PrefAboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sobre la aplicación',
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
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppLogoSection(),
              ContactInfoTile(
                icon: FontAwesomeIcons.solidEnvelope,
                text: 'contacto@fitnestx.com',
                onTapDescription: 'Abrir email o copiar',
              ),
              ContactInfoTile(
                icon: FontAwesomeIcons.phone,
                text: '+1 234 567 890',
                onTapDescription: 'Llamar o copiar',
              ),
              ContactInfoTile(
                icon: FontAwesomeIcons.globe,
                text: 'www.fitnestx.com',
                onTapDescription: 'Abrir navegador',
              ),
              SizedBox(height: 20),
              SocialButtonsRow(),
              SizedBox(height: 20),
              LegalLinks(),
              SizedBox(height: 20),
              FeedbackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
