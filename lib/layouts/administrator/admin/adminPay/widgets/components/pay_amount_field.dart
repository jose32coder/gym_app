import 'package:basic_flutter/components/validations.dart';
import 'package:flutter/material.dart';

class PayAmountField extends StatefulWidget {
  final String paymentCurrency;
  final TextEditingController amountUsdController;
  final TextEditingController amountBsController;
  final TextEditingController referenceAmountBsController;
  final void Function(bool hasError)? onValidationChanged;

  const PayAmountField({
    super.key,
    required this.paymentCurrency,
    required this.amountUsdController,
    required this.amountBsController,
    this.onValidationChanged,
    required this.referenceAmountBsController,
  });

  @override
  State<PayAmountField> createState() => PayAmountFieldState();
}

class PayAmountFieldState extends State<PayAmountField> {
  late FocusNode _focusAmountUsd;
  late FocusNode _focusAmountBs;
  late FocusNode _focusReference;

  String? _amountUsdError;
  String? _amountBsError;
  String? _referenceError;

  bool validate() {
    final usd = widget.amountUsdController.text.trim();
    final bs = widget.amountBsController.text.trim();

    if (usd.isEmpty && bs.isEmpty) {
      widget.onValidationChanged!(true);
      return false;
    }
    widget.onValidationChanged!(false);
    return true;
  }

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
              widget.referenceAmountBsController.text);
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
  void didUpdateWidget(covariant PayAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paymentCurrency != widget.paymentCurrency) {
      setState(() {
        _amountUsdError = null;
        _amountBsError = null;
        _referenceError = null;
      });
    }
  }

  bool validateFields() {
    setState(() {
      _amountUsdError = Validations.validateAmountBsAndDollar(
          widget.amountUsdController.text);
      _amountBsError =
          Validations.validateAmountBsAndDollar(widget.amountBsController.text);
      _referenceError = Validations.validateReferencia(
          widget.referenceAmountBsController.text);
    });

    bool hasError = (_amountUsdError != null) ||
        (_amountBsError != null) ||
        (_referenceError != null);
    widget.onValidationChanged?.call(hasError);
    return !hasError;
  }

  void _notifyValidation() {
    bool hasError = (_amountUsdError != null) ||
        (_amountBsError != null) ||
        (_referenceError != null);
    widget.onValidationChanged?.call(hasError);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.paymentCurrency == 'Bs') ...[
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
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _focusAmountBs.unfocus(),
            onChanged: (value) {
              setState(() {
                _amountBsError = Validations.validateAmountBsAndDollar(value);
                _notifyValidation();
              });
            },
            validator: (value) => Validations.validateAmountBsAndDollar(value),
          ),
          const SizedBox(height: 10), // Separación entre campos
          TextFormField(
            controller: widget.referenceAmountBsController,
            focusNode: _focusReference,
            decoration: InputDecoration(
              hintText: 'Referencia de pago',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.payment),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
            ),
            onChanged: (value) {
              setState(() {
                _referenceError = Validations.validateReferencia(value);
                _notifyValidation();
              });
            },
            validator: (value) => Validations.validateReferencia(value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _focusReference.unfocus(),
          ),
        ],
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
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) {
              _focusAmountUsd.unfocus();
              FocusScope.of(context).requestFocus(_focusAmountBs);
            },
            onChanged: (value) {
              setState(() {
                _amountUsdError = Validations.validateAmountBsAndDollar(value);
                _notifyValidation(); // <-- Aquí notifica al widget padre
              });
            },
            validator: (value) => Validations.validateAmountBsAndDollar(value),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.amountBsController,
            focusNode: _focusAmountBs,
            decoration: InputDecoration(
              hintText: 'Monto en Bs',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Bs',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) {
              _focusAmountBs.unfocus();
              FocusScope.of(context).requestFocus(_focusReference);
            },
            onChanged: (value) {
              setState(() {
                _amountBsError = Validations.validateAmountBsAndDollar(value);
                _notifyValidation();
              });
            },
            validator: (value) => Validations.validateAmountBsAndDollar(value),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.referenceAmountBsController,
            focusNode: _focusReference,
            decoration: InputDecoration(
              hintText: 'Referencia de pago',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.payment),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
              helperText: ' ',
            ),
            onChanged: (value) {
              setState(() {
                _referenceError = Validations.validateReferencia(value);
                _notifyValidation();
              });
            },
            validator: (value) => Validations.validateReferencia(value),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _focusReference.unfocus(),
          ),
        ],
      ],
    );
  }
}
