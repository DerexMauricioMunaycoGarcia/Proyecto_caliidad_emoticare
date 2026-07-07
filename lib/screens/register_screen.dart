import 'package:flutter/material.dart';
import 'package:proyecto_flutter_ia/services/usuario.dart';
import 'package:proyecto_flutter_ia/services/user_storage_service.dart';
import 'package:proyecto_flutter_ia/services/usuario.dart';

// 👈 Claves de acceso que ya usabas como credenciales fijas.
// Ahora se usan para confirmar que la persona realmente
// pertenece al rol que está seleccionando.
const String _claveDocente = 'tutor123';
const String _claveEstudiante = '123456';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _edadController = TextEditingController();
  final _claveAccesoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _rolSeleccionado; // "Estudiante" o "Docente"
  bool _claveValidada = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _enviando = false;
  bool _intentoEnviar = false;
  String? _errorGeneral;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _edadController.dispose();
    _claveAccesoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _claveEsperada =>
      _rolSeleccionado == 'Docente' ? _claveDocente : _claveEstudiante;

  void _onRolChanged(String rol) {
    setState(() {
      _rolSeleccionado = rol;
      // Si cambia de rol, hay que volver a validar la clave de acceso.
      _claveValidada = false;
      _claveAccesoController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _onClaveAccesoChanged(String value) {
    setState(() {
      _claveValidada = _rolSeleccionado != null && value == _claveEsperada;
    });
  }

  // --- Validación de la nueva contraseña ---
  bool get _tieneMayuscula => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _tieneNumero => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _tieneLetra => _passwordController.text.contains(RegExp(r'[a-zA-Z]'));
  bool get _tieneLongitudMinima => _passwordController.text.length >= 8;

  bool get _passwordValida =>
      _tieneMayuscula && _tieneNumero && _tieneLetra && _tieneLongitudMinima;

  bool get _passwordsCoinciden =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text;

  String _capitalizar(String texto) {
    final limpio = texto.trim();
    if (limpio.isEmpty) return limpio;
    return limpio[0].toUpperCase() + limpio.substring(1).toLowerCase();
  }

  Future<void> _registrar() async {
    setState(() {
      _intentoEnviar = true;
      _errorGeneral = null;
    });

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final edadTexto = _edadController.text.trim();

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        edadTexto.isEmpty ||
        _rolSeleccionado == null) {
      setState(() => _errorGeneral = "Por favor completa todos los campos.");
      return;
    }

    final edad = int.tryParse(edadTexto);
    if (edad == null || edad <= 0 || edad > 120) {
      setState(() => _errorGeneral = "Ingresa una edad válida.");
      return;
    }

    if (!_claveValidada) {
      setState(
        () => _errorGeneral = "La clave de acceso para el rol seleccionado es incorrecta.",
      );
      return;
    }

    if (!_passwordValida) {
      setState(
        () => _errorGeneral =
            "La contraseña debe tener letra, mayúscula, número y al menos 8 caracteres.",
      );
      return;
    }

    if (!_passwordsCoinciden) {
      setState(() => _errorGeneral = "Las contraseñas no coinciden.");
      return;
    }

    setState(() => _enviando = true);

    final email = "${_capitalizar(nombre)}.${_rolSeleccionado}@gmail.com";

    if (await UserStorageService.emailExiste(email)) {
      setState(() {
        _enviando = false;
        _errorGeneral =
            "Ya existe un usuario registrado con ese nombre y rol. Prueba con otro nombre.";
      });
      return;
    }

    final usuario = Usuario(
      nombre: _capitalizar(nombre),
      apellido: _capitalizar(apellido),
      edad: edad,
      rol: _rolSeleccionado!,
      email: email,
      password: _passwordController.text,
    );

    await UserStorageService.guardarUsuario(usuario);

    if (!mounted) return;
    setState(() => _enviando = false);

    _mostrarDialogoExito(email);
  }

 void _mostrarDialogoExito(String email) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "¡Registro exitoso!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Tu correo de acceso es:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.30),
                    ),
                  ),
                  child: SelectableText(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Ir a iniciar sesión",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: const Color(0xFF1E3A8A),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Crear cuenta",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Completa tus datos para registrarte",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      _campoTexto(
                        controller: _nombreController,
                        label: "Nombre",
                        icon: Icons.badge_outlined,
                        error:
                            _intentoEnviar && _nombreController.text.trim().isEmpty
                                ? "Este campo es obligatorio"
                                : null,
                      ),
                      const SizedBox(height: 16),

                      _campoTexto(
                        controller: _apellidoController,
                        label: "Apellido",
                        icon: Icons.badge_outlined,
                        error:
                            _intentoEnviar &&
                                    _apellidoController.text.trim().isEmpty
                                ? "Este campo es obligatorio"
                                : null,
                      ),
                      const SizedBox(height: 16),

                      _campoTexto(
                        controller: _edadController,
                        label: "Edad",
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        error:
                            _intentoEnviar && _edadController.text.trim().isEmpty
                                ? "Este campo es obligatorio"
                                : null,
                      ),
                      const SizedBox(height: 20),

                      // --- Selector de rol ---
                      Row(
                        children: const [
                          Text(
                            "¿Eres docente o estudiante?",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            " *",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _opcionRol(
                              label: "Estudiante",
                              icon: Icons.school_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _opcionRol(
                              label: "Docente",
                              icon: Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                      if (_intentoEnviar && _rolSeleccionado == null) ...[
                        const SizedBox(height: 6),
                        const Text(
                          "Selecciona un rol",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],

                      // --- Clave de acceso por rol ---
                      if (_rolSeleccionado != null) ...[
                        const SizedBox(height: 20),
                        _campoTexto(
                          controller: _claveAccesoController,
                          label:
                              "Clave de acceso de ${_rolSeleccionado!.toLowerCase()}",
                          icon: Icons.vpn_key_outlined,
                          obscure: true,
                          onChanged: _onClaveAccesoChanged,
                          suffixIcon:
                              _claveAccesoController.text.isEmpty
                                  ? null
                                  : Icon(
                                    _claveValidada
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        _claveValidada
                                            ? const Color(0xFF10B981)
                                            : Colors.red,
                                  ),
                          error:
                              _claveAccesoController.text.isNotEmpty &&
                                      !_claveValidada
                                  ? "Clave de acceso incorrecta"
                                  : null,
                        ),
                      ],

                      // --- Crear contraseña (se desbloquea solo si la clave es válida) ---
                      if (_claveValidada) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          "Crea tu contraseña de acceso",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _campoTexto(
                          controller: _passwordController,
                          label: "Nueva contraseña",
                          icon: Icons.lock_outline,
                          obscure: !_isPasswordVisible,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF3B82F6),
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                          ),
                          error:
                              _intentoEnviar &&
                                      _passwordController.text.isNotEmpty &&
                                      !_passwordValida
                                  ? "No cumple los requisitos"
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        _buildChecklistPassword(),
                        const SizedBox(height: 16),
                        _campoTexto(
                          controller: _confirmPasswordController,
                          label: "Confirmar contraseña",
                          icon: Icons.lock_outline,
                          obscure: !_isConfirmVisible,
                          onChanged: (_) => setState(() {}),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF3B82F6),
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _isConfirmVisible = !_isConfirmVisible,
                                ),
                          ),
                          error:
                              _confirmPasswordController.text.isNotEmpty &&
                                      !_passwordsCoinciden
                                  ? "Las contraseñas no coinciden"
                                  : null,
                        ),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _enviando
                                    ? Colors.grey
                                    : const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _enviando
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    "Registrarme",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),

                      if (_errorGeneral != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorGeneral!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _opcionRol({required String label, required IconData icon}) {
    final bool seleccionado = _rolSeleccionado == label;
    return InkWell(
      onTap: () => _onRolChanged(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              seleccionado
                  ? const Color(0xFF3B82F6).withOpacity(0.1)
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? const Color(0xFF3B82F6) : Colors.grey[300]!,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  seleccionado ? const Color(0xFF3B82F6) : Colors.grey[500],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    seleccionado
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistPassword() {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _chequeo("Mayúscula", _tieneMayuscula),
        _chequeo("Número", _tieneNumero),
        _chequeo("Letra", _tieneLetra),
        _chequeo("8+ caracteres", _tieneLongitudMinima),
      ],
    );
  }

  Widget _chequeo(String texto, bool cumple) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          cumple ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: cumple ? const Color(0xFF10B981) : Colors.grey[400],
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: cumple ? const Color(0xFF10B981) : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    String? error,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? Colors.red : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: error != null ? Colors.red : const Color(0xFF3B82F6),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        errorText: error,
      ),
    );
  }
}