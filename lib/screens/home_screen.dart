import 'package:flutter/material.dart';
import 'package:proyecto_flutter_ia/screens/login_screen.dart';
import 'package:proyecto_flutter_ia/services/evaluacion.dart';
import 'package:proyecto_flutter_ia/services/evaluacion_storage_service.dart';
import 'package:proyecto_flutter_ia/theme/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Evaluacion>? _evaluaciones;
  List<Evaluacion>? _filtradas;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedRiskFilter = "Todos los riesgos";
  final List<String> _riskFilterOptions = [
    "Todos los riesgos",
    "Alto riesgo",
    "Medio riesgo",
    "Bajo riesgo",
  ];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _cargarDatos();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final data = await EvaluationStorageService.obtenerEvaluaciones();
    setState(() {
      _evaluaciones = data;
      _filtradas = data;
    });
    _animationController.forward(from: 0);
  }

  void _filterData() {
    if (_evaluaciones == null) return;

    setState(() {
      final searchTerm = _searchController.text.toLowerCase();

      _filtradas =
          _evaluaciones!.where((e) {
            final matchesSearch =
                e.nombre.toLowerCase().contains(searchTerm) ||
                e.texto.toLowerCase().contains(searchTerm);

            bool matchesRisk = true;
            if (_selectedRiskFilter != "Todos los riesgos") {
              if (_selectedRiskFilter == "Alto riesgo") {
                matchesRisk = e.riesgoAgrupado == "alto";
              } else if (_selectedRiskFilter == "Medio riesgo") {
                matchesRisk = e.riesgoAgrupado == "medio";
              } else if (_selectedRiskFilter == "Bajo riesgo") {
                matchesRisk = e.riesgoAgrupado == "bajo";
              }
            }

            return matchesSearch && matchesRisk;
          }).toList();
    });
  }

  Map<String, int> _getStatistics() {
    if (_evaluaciones == null || _evaluaciones!.isEmpty) {
      return {"total": 0, "alto": 0, "medio": 0, "bajo": 0};
    }

    int alto = 0, medio = 0, bajo = 0;
    for (final e in _evaluaciones!) {
      switch (e.riesgoAgrupado) {
        case "alto":
          alto++;
          break;
        case "medio":
          medio++;
          break;
        case "bajo":
          bajo++;
          break;
      }
    }

    return {
      "total": _evaluaciones!.length,
      "alto": alto,
      "medio": medio,
      "bajo": bajo,
    };
  }

  // 👇 NUEVO: distribución de sentimiento
  Map<String, int> _getSentimentStats() {
    if (_evaluaciones == null || _evaluaciones!.isEmpty) {
      return {"positivo": 0, "neutral": 0, "negativo": 0};
    }
    int positivo = 0, neutral = 0, negativo = 0;
    for (final e in _evaluaciones!) {
      switch (e.sentimiento) {
        case "positivo":
          positivo++;
          break;
        case "negativo":
          negativo++;
          break;
        default:
          neutral++;
      }
    }
    return {"positivo": positivo, "neutral": neutral, "negativo": negativo};
  }

  // 👇 NUEVO: evaluaciones registradas en los últimos 7 días
  int _getEvaluacionesEstaSemana() {
    if (_evaluaciones == null) return 0;
    final haceUnaSemana = DateTime.now().subtract(const Duration(days: 7));
    return _evaluaciones!.where((e) => e.fecha.isAfter(haceUnaSemana)).length;
  }

  // 👇 NUEVO: estudiantes de riesgo alto/muy alto más recientes (máx. 5)
  List<Evaluacion> _getEstudiantesEnAtencion() {
    if (_evaluaciones == null) return [];
    final riesgosos =
        _evaluaciones!.where((e) => e.riesgoAgrupado == "alto").toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return riesgosos.take(5).toList();
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout, color: Color(0xFFEF4444)),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: TextStyle(color: _isDark ? Colors.white : null),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro que deseas cerrar sesión?',
            style: TextStyle(
              fontSize: 16,
              color: _isDark ? Colors.white70 : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: _isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();
    final sentimentStats = _getSentimentStats();
    final estaSemana = _getEvaluacionesEstaSemana();
    final enAtencion = _getEstudiantesEnAtencion();

    final Color cardColor = _isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor = _isDark ? Colors.white : const Color(0xFF1E293B);
    final Color subtitleColor = _isDark ? Colors.white60 : Colors.grey[600]!;
    final Color borderColor = _isDark ? Colors.white12 : Colors.grey[300]!;

    return Scaffold(
      backgroundColor:
          _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.dashboard_rounded, size: 28, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Panel de Control Docente",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            tooltip: _isDark ? "Modo claro" : "Modo oscuro",
            onPressed: ThemeController.toggle, // 👈 NUEVO
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Actualizar datos",
            onPressed: _cargarDatos,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _cerrarSesion();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xFFEF4444)),
                        SizedBox(width: 12),
                        Text('Cerrar Sesión'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          _evaluaciones == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Cargando datos...",
                      style: TextStyle(fontSize: 16, color: subtitleColor),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _cargarDatos,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarjetas de estadísticas
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Total Estudiantes",
                                "${stats['total']}",
                                Icons.people_rounded,
                                const Color(0xFF3B82F6),
                                const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Alto Riesgo",
                                "${stats['alto']}",
                                Icons.warning_rounded,
                                const Color(0xFFEF4444),
                                const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Medio Riesgo",
                                "${stats['medio']}",
                                Icons.info_rounded,
                                const Color(0xFFF59E0B),
                                const Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Bajo Riesgo",
                                "${stats['bajo']}",
                                Icons.check_circle_rounded,
                                const Color(0xFF10B981),
                                const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 👇 NUEVO: resumen rápido (semana + sentimiento predominante)
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Evaluaciones (7 días)",
                                "$estaSemana",
                                Icons.calendar_month_rounded,
                                const Color(0xFF6366F1),
                                const Color(0xFF4F46E5),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Sentimiento Predominante",
                                _sentimientoPredominante(sentimentStats),
                                Icons.emoji_emotions_rounded,
                                const Color(0xFF14B8A6),
                                const Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 👇 NUEVO: Estudiantes que requieren atención
                        if (enAtencion.isNotEmpty) ...[
                          _buildCardWrapper(
                            cardColor: cardColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  icon: Icons.priority_high_rounded,
                                  title: "Estudiantes que requieren atención",
                                  titleColor: titleColor,
                                  iconBg: const Color(0xFFEF4444),
                                ),
                                const SizedBox(height: 16),
                                ...enAtencion.map(
                                  (e) => _buildAtencionTile(
                                    e,
                                    borderColor,
                                    titleColor,
                                    subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Gráfico de barras: Distribución de riesgo
                        _buildCardWrapper(
                          cardColor: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                icon: Icons.bar_chart_rounded,
                                title: "Distribución de Riesgo",
                                titleColor: titleColor,
                                iconBg: const Color(0xFF3B82F6),
                              ),
                              const SizedBox(height: 24),
                              _buildBarChart(stats),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 👇 NUEVO: Distribución de sentimiento
                        _buildCardWrapper(
                          cardColor: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                icon: Icons.mood_rounded,
                                title: "Distribución de Sentimiento",
                                titleColor: titleColor,
                                iconBg: const Color(0xFF14B8A6),
                              ),
                              const SizedBox(height: 24),
                              _buildSentimentChart(sentimentStats),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tabla de datos con filtros
                        _buildCardWrapper(
                          cardColor: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                icon: Icons.table_chart_rounded,
                                title: "Datos de Estudiantes",
                                titleColor: titleColor,
                                iconBg: const Color(0xFF3B82F6),
                              ),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _searchController,
                                      style: TextStyle(color: titleColor),
                                      decoration: InputDecoration(
                                        hintText: "Buscar estudiante...",
                                        hintStyle: TextStyle(
                                          color: subtitleColor,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Color(0xFF3B82F6),
                                        ),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? IconButton(
                                                  icon: const Icon(
                                                    Icons.clear,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                  },
                                                )
                                                : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: borderColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF3B82F6),
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor:
                                            _isDark
                                                ? Colors.white.withOpacity(0.06)
                                                : Colors.grey[50],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _isDark
                                                ? Colors.white.withOpacity(0.06)
                                                : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedRiskFilter,
                                          isExpanded: true,
                                          dropdownColor: cardColor,
                                          items:
                                              _riskFilterOptions.map((opcion) {
                                                return DropdownMenuItem<String>(
                                                  value: opcion,
                                                  child: Text(
                                                    opcion,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: titleColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                _selectedRiskFilter = value;
                                                _filterData();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              if (_filtradas == null || _filtradas!.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _evaluaciones!.isEmpty
                                        ? "Aún no hay evaluaciones registradas."
                                        : "No se encontraron resultados.",
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              else
                                _buildTabla(cardColor, titleColor, borderColor),

                              const SizedBox(height: 16),
                              Text(
                                "Mostrando ${_filtradas?.length ?? 0} de ${_evaluaciones!.length} evaluaciones",
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  String _sentimientoPredominante(Map<String, int> s) {
    final entries =
        s.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty || entries.first.value == 0) return "N/A";
    return entries.first.key[0].toUpperCase() + entries.first.key.substring(1);
  }

  // --- Envoltorio genérico de tarjeta (adaptado a tema) ---
  Widget _buildCardWrapper({required Color cardColor, required Widget child}) {
    return Card(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color titleColor,
    required Color iconBg,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconBg, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
      ],
    );
  }

  // 👇 NUEVO: fila de un estudiante en riesgo
  Widget _buildAtencionTile(
    Evaluacion e,
    Color borderColor,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: titleColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${e.fechaFormateada} · ${e.riesgo.replaceAll('_', ' ')}",
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "ALTO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 👇 NUEVO: gráfico de barras de sentimiento
  Widget _buildSentimentChart(Map<String, int> s) {
    final maxValue =
        [
          s['positivo']!,
          s['neutral']!,
          s['negativo']!,
        ].reduce((a, b) => a > b ? a : b).toDouble();
    return Column(
      children: [
        _buildBar(
          "Positivo",
          s['positivo']!,
          maxValue,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        _buildBar("Neutral", s['neutral']!, maxValue, const Color(0xFFF59E0B)),
        const SizedBox(height: 16),
        _buildBar(
          "Negativo",
          s['negativo']!,
          maxValue,
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildTabla(Color cardColor, Color titleColor, Color borderColor) {
    const headers = [
      "Fecha",
      "Nombre",
      "Texto",
      "P1",
      "P2",
      "P3",
      "P4",
      "P5",
      "Sentimiento",
      "Riesgo",
      "Recomendación",
    ];

    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      headers.map((h) {
                        return Container(
                          width: 150,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            h,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Divider(height: 1, color: borderColor),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children:
                        _filtradas!.map((e) {
                          final celdas = [
                            e.fechaFormateada,
                            e.nombre,
                            e.texto,
                            ...e.respuestas,
                            e.sentimiento,
                            e.riesgo,
                            e.recomendacion,
                          ];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children:
                                  celdas.map((cell) {
                                    return Container(
                                      width: 150,
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        cell.toString(),
                                        style: TextStyle(
                                          color: titleColor.withOpacity(0.85),
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> stats) {
    final values = [stats['alto']!, stats['medio']!, stats['bajo']!];
    final maxValue =
        values.isEmpty
            ? 0.0
            : values.reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      children: [
        _buildBar("Alto", stats['alto']!, maxValue, const Color(0xFFEF4444)),
        const SizedBox(height: 16),
        _buildBar("Medio", stats['medio']!, maxValue, const Color(0xFFF59E0B)),
        const SizedBox(height: 16),
        _buildBar("Bajo", stats['bajo']!, maxValue, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildBar(String label, int value, double maxValue, Color color) {
    final percentage = maxValue > 0 ? (value / maxValue) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: _isDark ? Colors.white12 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
