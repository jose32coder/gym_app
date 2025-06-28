class Persona {
  final String nombre;
  final bool activa;

  Persona(this.nombre, this.activa);
}

class Membresia {
  final String tipo;
  final DateTime fechaVencimiento;
  final double pago;
  final bool vigente;

  Membresia(this.tipo, this.fechaVencimiento, this.pago, this.vigente);
}

class Ingreso {
  final DateTime fecha;
  final double monto;

  Ingreso(this.fecha, this.monto);
}

// Datos ejemplo:

final personas = List.generate(10, (i) => Persona('Persona $i', i % 2 == 0));
final membresias = [
  Membresia('Básica', DateTime.now().add(const Duration(days: 10)), 20, true),
  Membresia('Premium', DateTime.now().subtract(const Duration(days: 2)), 50, false),
  Membresia('Básica', DateTime.now().add(const Duration(days: 40)), 20, true),
  Membresia('VIP', DateTime.now().add(const Duration(days: 3)), 100, true),
  Membresia('Premium', DateTime.now().add(const Duration(days: 5)), 50, true),
  // ...
];

final ingresos = List.generate(7, (i) => Ingreso(DateTime.now().subtract(Duration(days: i)), 100.0 + i * 20));
