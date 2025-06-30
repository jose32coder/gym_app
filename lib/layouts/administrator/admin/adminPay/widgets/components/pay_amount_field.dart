import 'package:basic_flutter/components/validations.dart';
import 'package:flutter/material.dart';

class PayAmountField extends StatefulWidget {
  final String paymentCurrency;
  final TextEditingController amountUsdController;
  final TextEditingController amountBsController;
  final TextEditingController paymentReferenceController;
  final FormFieldValidator<String>? validateAmount;

  const PayAmountField(
      {super.key,
      required this.paymentCurrency,
      required this.amountUsdController,
      required this.amountBsController,
      required this.validateAmount,
      required this.paymentReferenceController});

  @override
  State<PayAmountField> createState() => _PayAmountFieldState();
}

class _PayAmountFieldState extends State<PayAmountField> {
  late FocusNode _focusAmountUsd;
  late FocusNode _focusAmountBs;
  late FocusNode _focusReference;

  String? _amountUsdError;
  String? _amountBsError;
  String? _referenceError;

  @override
  void initState() {
    super.initState();
    _focusAmountUsd = FocusNode();
    _focusAmountBs = FocusNode();
    _focusReference = FocusNode();

    _focusAmountBs.addListener(() {
      if (!_focusAmountBs.hasFocus) {
        setState(() {
          _amountBsError = Validations.validateAmountBsAndDollar(
              widget.amountBsController.text);
        });
      }
    });

    _focusAmountUsd.addListener(() {
      if (!_focusAmountUsd.hasFocus) {
        setState(() {
          _amountUsdError = Validations.validateAmountBsAndDollar(
              widget.amountUsdController.text);
        });
      }
    });

    _focusReference.addListener(() {
      if (!_focusReference.hasFocus) {
        setState(() {
          _referenceError = Validations.validateReferencia(
              widget.paymentReferenceController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _focusAmountUsd.dispose();
    _focusAmountBs.dispose();
    _focusReference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.paymentCurrency == 'Bs')
          TextFormField(
            controller: widget.amountBsController,
            focusNode: _focusAmountBs,
            decoration: InputDecoration(
              hintText: 'Monto en Bs',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.attach_money),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
              errorText: _amountBsError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _focusAmountBs.unfocus(),
          ),
        if (widget.paymentCurrency == 'Ambos') ...[
          TextFormField(
            controller: widget.amountUsdController,
            focusNode: _focusAmountUsd,
            decoration: InputDecoration(
              hintText: 'Monto en \$',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.attach_money),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
              errorText: _amountUsdError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) {
              _focusAmountUsd.unfocus();
              FocusScope.of(context).requestFocus(_focusAmountBs);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.amountBsController,
            focusNode: _focusAmountBs,
            decoration: InputDecoration(
              hintText: 'Monto en Bs',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.attach_money),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
              errorText: _amountBsError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) {
              _focusAmountBs.unfocus();
              FocusScope.of(context).requestFocus(_focusReference);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.paymentReferenceController,
            focusNode: _focusReference,
            decoration: InputDecoration(
              hintText: 'Referencia de pago',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.payment),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
              errorText: _referenceError,
            ),
            onChanged: (value) {
              setState(() {
                _referenceError = Validations.validateReferencia(value);
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _focusReference.unfocus(),
          ),
        ],
      ],
    );
  }
}
