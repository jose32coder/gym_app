import 'package:flutter/material.dart';

class PaymentCurrencySelector extends StatelessWidget {
  final String paymentCurrency;
  final ValueChanged<String?> onChanged;

  const PaymentCurrencySelector({
    super.key,
    required this.paymentCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: paymentCurrency,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.monetization_on),
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        filled: true,
      ),
      items: ['Dólares', 'Bs', 'Ambos']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
