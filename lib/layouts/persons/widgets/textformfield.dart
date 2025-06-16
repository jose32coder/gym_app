import 'package:basic_flutter/components/text_style.dart';
import 'package:basic_flutter/components/validations.dart';
import 'package:basic_flutter/layouts/persons/widgets/genero_selector.dart';
import 'package:basic_flutter/layouts/admin/adminPay/payViews/pay_register.dart';
import 'package:basic_flutter/models/user_register_models.dart';
import 'package:basic_flutter/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFormPage extends StatefulWidget {
  const TextFormPage({
    super.key,
  });

  @override
  State<TextFormPage> createState() => _TextFormPageState();
}

class _TextFormPageState extends State<TextFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cedController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // FocusNodes para detectar pérdida de foco
  late FocusNode _cedFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _lastnameFocusNode;
  late FocusNode _emailFocusNode;

  bool isLoading = false;
  // Variables para almacenar mensajes de error en tiempo real
  String? _cedError;
  String? _nameError;
  String? _lastnameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _cedFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _lastnameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();

    // Escuchar pérdida de foco y validar
    _cedFocusNode.addListener(() {
      if (!_cedFocusNode.hasFocus) {
        setState(() {
          _cedError = Validations.validateCed(_cedController.text);
        });
      }
    });

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        setState(() {
          _nameError = Validations.validateName(_nameController.text);
        });
      }
    });
    _lastnameFocusNode.addListener(() {
      if (!_lastnameFocusNode.hasFocus) {
        setState(() {
          _lastnameError = Validations.validateName(_lastnameController.text);
        });
      }
    });
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = Validations.validateEmail(_emailController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _cedFocusNode.dispose();
    _nameFocusNode.dispose();
    _lastnameFocusNode.dispose();
    _emailFocusNode.dispose();
    _cedController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _registerClient() async {
    final usuarioVM = Provider.of<UserViewmodel>(context, listen: false);

    final nuevaPersona = UserRegisterModels(
      cedula: _cedController.text.trim(),
      nombre: _nameController.text.trim(),
      apellido: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      tipo: 'cliente',
      tieneUsuario: 'no',
    );

    await usuarioVM.registerPerson(nuevaPersona);
    
    setState(() {
      _cedError = Validations.validateCed(_cedController.text);
      _nameError = Validations.validateName(_nameController.text);
      _lastnameError = Validations.validateName(_lastnameController.text);
      _emailError = Validations.validateEmail(_emailController.text);
    });

    if (_formKey.currentState!.validate() &&
        _cedError == null &&
        _nameError == null &&
        _lastnameError == null &&
        _emailError == null) {
      setState(() {
        isLoading = true;
      });

      final bool? pagarAhora = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Deseas pagar la membresía ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Solo registrar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Pagar ahora'),
            ),
          ],
        ),
      );

      if (pagarAhora != null) {
        if (pagarAhora) {
          // Navegar a Membership con pagoInmediato = true
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PayRegister(
                desdeAdmin: false,
                cedula: '12345678',
                nombreCompleto: 'Jose Perez',
              ),
            ),
          );
        } else {
          // Solo registro sin pago
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membresía registrada sin pago')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cédula',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
              controller: _cedController,
              focusNode: _cedFocusNode,
              decoration: InputDecoration(
                hintText: 'Introduce la cédula',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.badge),
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                filled: true,
              ).copyWith(errorText: _cedError),
              validator: Validations.validateCed),
          const SizedBox(height: 20),
          Text(
            'Nombre',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              hintText: 'Introduce el nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.account_circle),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _nameError),
            validator: Validations.validateName,
          ),
          const SizedBox(height: 15),
          Text(
            'Apellido',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _lastnameController,
            focusNode: _lastnameFocusNode,
            decoration: InputDecoration(
              hintText: 'Introduce el apellido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.account_circle),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _nameError),
            validator: Validations.validateName,
          ),
          const SizedBox(height: 20),
          const GeneroSelector(),
          const SizedBox(height: 20),
          Text(
            'Correo',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              hintText: 'Correo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.email_rounded),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _emailError),
            validator: Validations.validateEmail,
          ),
          const SizedBox(height: 20),
          Text(
            'Contraseña',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              hintText: 'Contreaseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.lock_rounded),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _emailError),
            validator: Validations.validatePassword,
          ),
          const SizedBox(height: 20),
          Text(
            'Codigo',
            style: TextStyles.boldText(context),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              hintText: 'Codigo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.qr_code),
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              filled: true,
            ).copyWith(errorText: _emailError),
            validator: Validations.validateEmail,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _registerClient,
              icon: Icon(Icons.login, color: theme.colorScheme.onSurface),
              label: Text(
                'Registrar',
                style:
                    TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
