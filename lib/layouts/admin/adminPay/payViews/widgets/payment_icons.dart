import 'package:flutter/material.dart';

Icon getPaymentIcon(String tipoPago, Color color) {
  switch (tipoPago) {
    case 'Bolívares (Bs)':
      return Icon(Icons.monetization_on, color: color);
    case 'Dólares (\$)':
      return Icon(Icons.attach_money, color: color);
    case 'Ambos':
      return Icon(Icons.account_balance_wallet, color: color);
    default:
      return Icon(Icons.payment, color: color);
  }
}
