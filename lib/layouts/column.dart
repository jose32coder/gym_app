import 'package:flutter/material.dart';

class ColumnExample extends StatelessWidget {
  const ColumnExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Hello Flutter!'),
        ],
      ),
    );
  }
}
