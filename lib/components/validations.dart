class Validations {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final email = value.trim();
    final parts = email.split('@');

    if (parts.length != 2) {
      return 'El correo debe contener exactamente un @';
    }

    final local = parts[0];
    final domain = parts[1];

    final emailLocalRegex = RegExp(r'^[\w.\-]+$');
    if (!emailLocalRegex.hasMatch(local)) {
      return 'Caracteres inválidos en la parte local';
    }

    final emailDomainRegex = RegExp(r'^[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailDomainRegex.hasMatch(domain)) {
      return 'Dominio inválido (ejemplo válido: gmail.com)';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final regex = RegExp(r'^(0424|0412|0414|0416|0426)\d{7}$');

    if (!regex.hasMatch(value)) {
      return 'Número de teléfono inválido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateNewPassword(String value) {
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  static String? validateReferencia(String? value) {
    if (value == null || value.isEmpty) {
      return 'La referencia es requerida';
    }
    if (value.length < 4) {
      return 'La referencia debe tener al menos 4 números';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'La referencia debe contener solo números';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final name = value.trim();

    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');

    if (!nameRegex.hasMatch(name)) {
      return 'Solo se permiten letras y espacios';
    }

    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es obligatorio';
    }
    final numValue = num.tryParse(value);
    if (numValue == null || numValue <= 0) {
      return 'Debe ser un número mayor a 0';
    }
    return null;
  }

  static String? validateAmountBsAndDollar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Coloca un monto valido';
    }
    final numValue = num.tryParse(value);
    if (numValue == null || numValue <= 0) {
      return 'Debe ser un número mayor a 0';
    }
    return null;
  }

  static String? validateMembershipName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la membresía es obligatorio';
    }
    return null;
  }

  static String? validatePromotionName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la promoción es obligatorio';
    }
    return null;
  }

  static String? validateCed(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es requerida';
    }

    // Limpiar: eliminar espacios y convertir a mayúsculas
    String cleanValue = value.replaceAll(' ', '').toUpperCase();

    final regex = RegExp(r'^(?:[VE]?)?\d{7,8}$');

    if (!regex.hasMatch(cleanValue)) {
      return 'Cédula inválida. Ej: 12345678';
    }

    return null;
  }

  static String? validateSex(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecciona un sexo';
    }

    return null;
  }

  static String? validateTipoMember(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecciona una membresía';
    }

    return null;
  }

  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Codigo vacío';
    }
    return null;
  }
}
