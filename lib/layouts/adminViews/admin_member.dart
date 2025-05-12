import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class AdminMember extends StatelessWidget {
  const AdminMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Membresías', style: TextStyles.boldText(context)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
          )
        ],
      ),
      body: Center(
        child: Text('Membresías generales'),
      ),
    );
  }
}
