import 'package:flutter/material.dart';
import 'package:proyecto_flutter_ia/screens/student_screen.dart';
import 'package:proyecto_flutter_ia/screens/register_screen.dart';
import 'package:proyecto_flutter_ia/screens/home_screen.dart';
import 'package:proyecto_flutter_ia/services/user_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 👇 NUEVO: detecta si el tema activo es oscuro
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Por favor completa todos los campos.";
      });
      return;
    }

    // Administrador principal
    if (email == "admin.maestro@gmail.com" && password == "tutor123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
      return;
    }

    // Usuarios registrados
    final usuario = await UserStorageService.validarCredenciales(
      email,
      password,
    );

    if (usuario == null) {
      setState(() {
        _errorMessage = "Correo o contraseña incorrectos.";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    if (usuario.rol == "Docente") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentScreen(username: usuario.nombreCompleto),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  color:
                      _isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white, // 👈 NUEVO
                  elevation: 12,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white, // 👈 NUEVO
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ClipOval(
                              child: Image.asset(
                                "assets/logo.png",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return const Icon(
                                    Icons.school,
                                    size: 64,
                                    color: Color(0xFF3B82F6),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          "Bienvenido",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                _isDark
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A), // 👈 NUEVO
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Inicia sesión para continuar",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _isDark
                                    ? Colors.white60
                                    : Colors.grey[600], // 👈 NUEVO
                          ),
                        ),

                        const SizedBox(height: 32),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color:
                                _isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B), // 👈 NUEVO
                          ),
                          decoration: InputDecoration(
                            labelText: "Correo electrónico",
                            labelStyle: TextStyle(
                              color:
                                  _isDark
                                      ? Colors.white54
                                      : Colors.grey[600], // 👈 NUEVO
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF3B82F6),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    _isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300, // 👈 NUEVO
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                _isDark
                                    ? Colors.white.withOpacity(0.06) // 👈 NUEVO
                                    : Colors.grey.shade50,
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(
                            color:
                                _isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B), // 👈 NUEVO
                          ),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            labelStyle: TextStyle(
                              color:
                                  _isDark
                                      ? Colors.white54
                                      : Colors.grey[600], // 👈 NUEVO
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF3B82F6),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF3B82F6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    _isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300, // 👈 NUEVO
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                _isDark
                                    ? Colors.white.withOpacity(0.06) // 👈 NUEVO
                                    : Colors.grey.shade50,
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿No tienes una cuenta?",
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    _isDark ? Colors.white70 : null, // 👈 NUEVO
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Regístrate",
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  _isDark
                                      ? Colors.red.withOpacity(0.15) // 👈 NUEVO
                                      : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    _isDark
                                        ? Colors.red.withOpacity(
                                          0.4,
                                        ) // 👈 NUEVO
                                        : Colors.red.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color:
                                      _isDark
                                          ? Colors.red[300]
                                          : Colors.red.shade700, // 👈 NUEVO
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color:
                                          _isDark
                                              ? Colors.red[300]
                                              : Colors.red.shade700, // 👈 NUEVO
                                      fontSize: 14,
                                    ),
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
      ),
    );
  }
}
