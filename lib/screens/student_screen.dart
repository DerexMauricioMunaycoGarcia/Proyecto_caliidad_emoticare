import 'package:flutter/material.dart';
import 'package:proyecto_flutter_ia/services/evaluacion_storage_service.dart';
import 'package:proyecto_flutter_ia/widgets/chatbot_floating.dart';
import 'package:proyecto_flutter_ia/screens/login_screen.dart';
import 'package:proyecto_flutter_ia/services/analysis_service.dart';
import 'package:proyecto_flutter_ia/services/evaluacion.dart';
import 'package:proyecto_flutter_ia/theme/theme_controller.dart';

class StudentScreen extends StatefulWidget {
  final String username;

  const StudentScreen({super.key, required this.username});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final PageController _pageController = PageController();

  final List<String> _opciones = [
    "Nunca",
    "A veces",
    "Frecuentemente",
    "Siempre",
  ];
  final List<String?> _respuestas = List.filled(5, null);

  bool _enviando = false;
  int _currentStep = 0; // 0 = texto libre, 1..5 = preguntas
  bool _intentoAvanzar = false; // valida solo el paso actual

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const int _totalSteps = 6;
  static const int _maxChars = 300;

  final List<String> _preguntas = [
    "¿Con qué frecuencia te sientes desmotivado?",
    "¿Has perdido interés en actividades que antes disfrutabas?",
    "¿Te cuesta concentrarte en tus tareas diarias?",
    "¿Sientes tristeza sin una razón aparente?",
    "¿Tienes problemas para dormir o descansar bien?",
  ];

  final List<String> _preguntasCortas = [
    "Expresión libre",
    "Motivación",
    "Interés",
    "Concentración",
    "Tristeza",
    "Sueño",
  ];

  final List<IconData> _iconosPreguntas = [
    Icons.sentiment_dissatisfied_outlined,
    Icons.interests_outlined,
    Icons.psychology_outlined,
    Icons.mood_bad_outlined,
    Icons.bedtime_outlined,
  ];

  final List<String> _tips = [
    "Tómate un momento. No hay respuestas correctas o incorrectas, solo tu forma de sentir hoy.",
    "Todos tenemos días de baja energía. Reconocerlo ya es un paso importante.",
    "Está bien si algo que antes disfrutabas hoy se siente distinto.",
    "La concentración también depende de cómo dormimos y comemos, no solo de la voluntad.",
    "La tristeza sin motivo aparente es más común de lo que crees, y hablar de ella ayuda.",
    "Dormir bien es la base del bienestar emocional. Sé honesto con esta respuesta.",
  ];

  List<Color> get _accentColors => [
    AppPalette.indigo,
    AppPalette.sage,
    AppPalette.amber,
    AppPalette.coral,
    AppPalette.indigoDeep,
    AppPalette.sage,
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _textController.addListener(() {
      if (_intentoAvanzar) setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  IconData get _iconoPasoActual =>
      _currentStep == 0
          ? Icons.edit_note_rounded
          : _iconosPreguntas[_currentStep - 1];

  bool _pasoValido(int paso) {
    if (paso == 0) return _textController.text.trim().isNotEmpty;
    return _respuestas[paso - 1] != null;
  }

  bool get _formularioCompleto =>
      _textController.text.trim().isNotEmpty && !_respuestas.contains(null);

  void _irSiguiente() {
    setState(() => _intentoAvanzar = true);
    if (!_pasoValido(_currentStep)) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _intentoAvanzar = false;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _enviarFormulario();
    }
  }

  void _irAtras() {
    if (_currentStep == 0) return;
    setState(() {
      _currentStep--;
      _intentoAvanzar = false;
    });
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _enviarFormulario() async {
    setState(() => _intentoAvanzar = true);
    if (!_formularioCompleto) return;

    setState(() => _enviando = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    String sentimiento = AnalysisService.analizarSentimiento(
      _textController.text,
    );
    String nivelRiesgo = AnalysisService.calcularNivelRiesgo(_respuestas);
    String recomendacion = AnalysisService.generarRecomendacion(
      nivelRiesgo,
      sentimiento,
    );

    final evaluacion = Evaluacion(
      nombre: widget.username,
      fecha: DateTime.now(),
      texto: _textController.text.trim(),
      respuestas: _respuestas.map((r) => r ?? '').toList(),
      sentimiento: sentimiento,
      riesgo: nivelRiesgo,
      recomendacion: recomendacion,
    );
    await EvaluationStorageService.guardarEvaluacion(evaluacion);

    setState(() => _enviando = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight:
                    MediaQuery.of(context).size.height * 0.85, // 👈 agregado
              ),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isDark ? AppPalette.navyCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    // 👈 agregado
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppPalette.indigo,
                                AppPalette.indigoDeep,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppPalette.indigo.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Evaluación Completada",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                _isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Hemos analizado tu evaluación emocional",
                          style: TextStyle(
                            fontSize: 14,
                            color: _isDark ? Colors.white70 : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppPalette.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppPalette.indigo.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppPalette.indigo,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Estudiante",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            _isDark
                                                ? Colors.white60
                                                : const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      widget.username,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _isDark
                                                ? Colors.white
                                                : const Color(0xFF1E293B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  sentimiento == "positivo"
                                      ? [
                                        AppPalette.sage,
                                        const Color(0xFF3E8A6C),
                                      ]
                                      : (sentimiento == "negativo"
                                          ? [
                                            AppPalette.coral,
                                            const Color(0xFFC94B62),
                                          ]
                                          : [
                                            AppPalette.amber,
                                            const Color(0xFFD9873C),
                                          ]),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                sentimiento == "positivo"
                                    ? Icons.sentiment_satisfied_rounded
                                    : (sentimiento == "negativo"
                                        ? Icons.sentiment_dissatisfied_rounded
                                        : Icons.sentiment_neutral_rounded),
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Sentimiento detectado",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      sentimiento.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _isDark
                                    ? AppPalette.navyCardAlt
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _isDark ? Colors.white24 : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      _isDark
                                          ? AppPalette.navyCard
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  nivelRiesgo.toLowerCase().contains("alto")
                                      ? Icons.warning_rounded
                                      : (nivelRiesgo.toLowerCase().contains(
                                            "medio",
                                          )
                                          ? Icons.info_rounded
                                          : Icons.check_circle_rounded),
                                  color:
                                      nivelRiesgo.toLowerCase().contains("alto")
                                          ? AppPalette.coral
                                          : (nivelRiesgo.toLowerCase().contains(
                                                "medio",
                                              )
                                              ? AppPalette.amber
                                              : AppPalette.sage),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nivel de riesgo",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            _isDark
                                                ? Colors.white60
                                                : const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      nivelRiesgo
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _isDark
                                                ? Colors.white
                                                : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppPalette.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppPalette.indigo.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    color: AppPalette.indigo,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Recomendación",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppPalette.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recomendacion,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _isDark
                                          ? Colors.white70
                                          : const Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppPalette.indigo,
                                AppPalette.indigoDeep,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppPalette.indigo.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text("Datos guardados correctamente"),
                                    ],
                                  ),
                                  backgroundColor: AppPalette.sage,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Entendido",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ), // 👈 cierre del SingleChildScrollView
                ),
              ),
            ),
          ),
    );

    _textController.clear();
    for (int i = 0; i < _respuestas.length; i++) {
      _respuestas[i] = null;
    }
    setState(() {
      _intentoAvanzar = false;
      _currentStep = 0;
    });
    _pageController.jumpToPage(0);
  }

  Color _getColorForOption(String option) {
    switch (option) {
      case "Nunca":
        return AppPalette.sage;
      case "A veces":
        return AppPalette.indigo;
      case "Frecuentemente":
        return AppPalette.amber;
      case "Siempre":
        return AppPalette.coral;
      default:
        return Colors.grey;
    }
  }

  void _mostrarMenuConfiguracion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDark ? AppPalette.navyCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppPalette.indigo,
                ),
                title: Text(_isDark ? "Modo claro" : "Modo oscuro"),
                textColor: _isDark ? Colors.white : null,
                onTap: () {
                  ThemeController.toggle();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppPalette.coral),
                title: Text(
                  "Cerrar sesión",
                  style: TextStyle(color: _isDark ? Colors.white : null),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppPalette.indigoDeep, AppPalette.indigo],
            ),
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology, size: 28, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Evaluación Emocional",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            tooltip: _isDark ? "Modo claro" : "Modo oscuro",
            onPressed: ThemeController.toggle,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _mostrarMenuConfiguracion,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildFondoDecorativo(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopHeader(),
                            const SizedBox(height: 20),
                            Expanded(
                              child:
                                  isWide
                                      ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: _buildWizardCard(),
                                          ),
                                          const SizedBox(width: 24),
                                          Expanded(
                                            flex: 2,
                                            child: _buildIllustrationPanel(),
                                          ),
                                        ],
                                      )
                                      : SingleChildScrollView(
                                        child: _buildWizardCard(),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const ChatbotFloating(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- FONDO DECORATIVO (H) ---

  Widget _buildFondoDecorativo() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _buildBlob(
                280,
                _accentColors[_currentStep].withOpacity(_isDark ? 0.16 : 0.14),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _buildBlob(
                320,
                AppPalette.indigo.withOpacity(_isDark ? 0.14 : 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }

  // --- HEADER SUPERIOR: saludo + progreso ---

  Widget _buildTopHeader() {
    final iniciales = _getIniciales(widget.username);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDark ? AppPalette.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppPalette.indigo, AppPalette.indigoDeep],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola, ${widget.username.split(' ').first}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Paso ${_currentStep + 1} de $_totalSteps · ${_preguntasCortas[_currentStep]}",
                      style: TextStyle(
                        fontSize: 13,
                        color: _isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_totalSteps, (i) {
              final activo = i <= _currentStep;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i == _totalSteps - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color:
                        activo
                            ? _accentColors[i]
                            : (_isDark ? Colors.white12 : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getIniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return "?";
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }

  // --- TARJETA DEL WIZARD (A) ---

  Widget _buildWizardCard() {
    final accent = _accentColors[_currentStep];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _isDark ? AppPalette.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withOpacity(_isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_iconoPasoActual, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _currentStep == 0
                      ? "¿Cómo te sientes hoy?"
                      : _preguntas[_currentStep - 1],
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: _isDark ? Colors.white : const Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child:
                  _currentStep == 0
                      ? _buildFreeTextStep()
                      : _buildOptionChips(_currentStep - 1),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: _enviando ? null : _irAtras,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text("Atrás"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _isDark ? Colors.white70 : const Color(0xFF475569),
                    side: BorderSide(
                      color: _isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _irSiguiente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _enviando ? Colors.grey : accent,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _enviando
                          ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Enviando...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentStep == _totalSteps - 1
                                    ? "Enviar evaluación"
                                    : "Siguiente",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentStep == _totalSteps - 1
                                    ? Icons.send_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTextStep() {
    final mostrarError = _intentoAvanzar && _textController.text.trim().isEmpty;
    final longitud = _textController.text.length;
    final cercaDelLimite = longitud > _maxChars * 0.85;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Escribe libremente. Nadie más que tu docente podrá ver esto.",
          style: TextStyle(
            fontSize: 13,
            color: _isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          maxLines: 5,
          maxLength: _maxChars,
          style: TextStyle(
            color: _isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: "Ej: Hoy me sentí un poco cansado, pero motivado...",
            hintStyle: TextStyle(
              color: _isDark ? Colors.white38 : Colors.grey[400],
            ),
            counterText: "",
            filled: true,
            fillColor: _isDark ? AppPalette.navyCardAlt : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color:
                    mostrarError
                        ? AppPalette.coral
                        : (_isDark ? Colors.white12 : Colors.grey.shade300),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: mostrarError ? AppPalette.coral : AppPalette.indigo,
                width: 2,
              ),
            ),
            errorText:
                mostrarError ? "Cuéntanos algo antes de continuar" : null,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "$longitud/$_maxChars",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  cercaDelLimite
                      ? AppPalette.coral
                      : (_isDark ? Colors.white38 : Colors.grey[500]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChips(int preguntaIndex) {
    final mostrarError = _intentoAvanzar && _respuestas[preguntaIndex] == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _opciones.map((opcion) {
                final seleccionado = _respuestas[preguntaIndex] == opcion;
                final color = _getColorForOption(opcion);
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      _respuestas[preguntaIndex] = opcion;
                      if (_intentoAvanzar) _intentoAvanzar = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          seleccionado
                              ? color
                              : (_isDark
                                  ? AppPalette.navyCardAlt
                                  : Colors.grey[50]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            seleccionado
                                ? color
                                : (mostrarError
                                    ? AppPalette.coral
                                    : (_isDark
                                        ? Colors.white12
                                        : Colors.grey.shade300)),
                        width: seleccionado ? 0 : 1.4,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (seleccionado)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                        else
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          opcion,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                seleccionado
                                    ? Colors.white
                                    : (_isDark
                                        ? Colors.white70
                                        : const Color(0xFF1E293B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
        if (mostrarError) ...[
          const SizedBox(height: 10),
          const Text(
            "Selecciona una opción antes de continuar",
            style: TextStyle(color: AppPalette.coral, fontSize: 13),
          ),
        ],
      ],
    );
  }

  // --- PANEL ILUSTRADO (C + I): mood orb + tip + resumen de pasos ---

  Widget _buildIllustrationPanel() {
    final accent = _accentColors[_currentStep];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDark ? AppPalette.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 2), // antes: 4
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 84, // antes: 100
            height: 84, // antes: 100
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withOpacity(_isDark ? 0.35 : 0.22),
                  accent.withOpacity(0),
                ],
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 54, // antes: 64
                height: 54, // antes: 64
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  _iconoPasoActual,
                  color: Colors.white,
                  size: 24,
                ), // antes: 28
              ),
            ),
          ),
          const SizedBox(height: 10), // antes: 14
          Text(
            _preguntasCortas[_currentStep],
            style: TextStyle(
              fontSize: 15, // antes: 16
              fontWeight: FontWeight.bold,
              color: _isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4), // antes: 6
          Text(
            _tips[_currentStep],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5, // antes: 13
              height: 1.35, // antes: 1.4
              color: _isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 14), // antes: 20
          Divider(color: _isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 2), // antes: 4
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "RECORRIDO DE LA EVALUACIÓN",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: _isDark ? Colors.white38 : Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 8), // antes: 12
          _buildStepperTimeline(),
        ],
      ),
    );
  }

  Widget _buildStepperTimeline() {
    return Column(
      children: List.generate(_totalSteps, (i) {
        final completado = i < _currentStep;
        final actual = i == _currentStep;
        final esUltimo = i == _totalSteps - 1;
        final color = _accentColors[i];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 22, // antes: 26
                    height: 22, // antes: 26
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          completado
                              ? color
                              : (actual
                                  ? Colors.transparent
                                  : (_isDark
                                      ? Colors.white10
                                      : Colors.grey[100])),
                      border: Border.all(
                        color:
                            completado
                                ? color
                                : (actual
                                    ? color
                                    : (_isDark
                                        ? Colors.white24
                                        : Colors.grey[300]!)),
                        width: actual ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child:
                          completado
                              ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              ) // antes: 15
                              : Text(
                                "${i + 1}",
                                style: TextStyle(
                                  fontSize: 10, // antes: 11
                                  fontWeight: FontWeight.bold,
                                  color:
                                      actual
                                          ? color
                                          : (_isDark
                                              ? Colors.white38
                                              : Colors.grey[400]),
                                ),
                              ),
                    ),
                  ),
                  if (!esUltimo)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: 1,
                        ), // antes: 2
                        color:
                            completado
                                ? color.withOpacity(0.5)
                                : (_isDark ? Colors.white12 : Colors.grey[200]),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10), // antes: 12
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: esUltimo ? 0 : 12,
                    top: 2,
                  ), // antes: 18 / 3
                  child: Text(
                    _preguntasCortas[i],
                    style: TextStyle(
                      fontSize: 12.5, // antes: 13
                      fontWeight: actual ? FontWeight.bold : FontWeight.w500,
                      color:
                          actual
                              ? (_isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B))
                              : (completado
                                  ? (_isDark
                                      ? Colors.white70
                                      : Colors.grey[700])
                                  : (_isDark
                                      ? Colors.white38
                                      : Colors.grey[400])),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
