import 'package:basic_flutter/components/text_style.dart';
import 'package:flutter/material.dart';

class AdminPay extends StatelessWidget {
  const AdminPay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text('Pagos', style: TextStyles.boldText(context),),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.add_alert),
          )
        ],
      ),
      body: const Center(
        child: Text('Pagos generales'),
      ),
    );
  }
}
