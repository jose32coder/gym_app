import 'package:flutter/material.dart';

class PayAmountField extends StatelessWidget {
  final String paymentCurrency;
  final TextEditingController amountUsdController;
  final TextEditingController amountBsController;
  final FormFieldValidator<String>? validateAmount;

  const PayAmountField({
    super.key,
    required this.paymentCurrency,
    required this.amountUsdController,
    required this.amountBsController,
    required this.validateAmount,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // if (paymentCurrency == 'Dólares')
        //   TextFormField(
        //     controller: amountUsdController,
        //     decoration: InputDecoration(
        //       hintText: 'Monto en \$',
        //       border:
        //           OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        //       prefixIcon: const Icon(Icons.attach_money),
        //       fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        //       filled: true,
        //       helperText: ' ',
        //     ),
        //     keyboardType: const TextInputType.numberWithOptions(decimal: true),
        //     validator: validateAmount,
        //   ),
        if (paymentCurrency == 'Bs')
          TextFormField(
            controller: amountBsController,
            decoration: InputDecoration(
              hintText: 'Monto en Bs',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.attach_money),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validateAmount,
          ),
        if (paymentCurrency == 'Ambos') ...[
          TextFormField(
            controller: amountBsController,
            decoration: InputDecoration(
              hintText: 'Monto en Bs',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.attach_money),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validateAmount,
          ),
          // const SizedBox(height: 10),
          TextFormField(
            controller: amountUsdController,
            decoration: InputDecoration(
              hintText: 'Monto en \$',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.attach_money),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: validateAmount,
          ),
        ],
      ],
    );
  }
}
