import 'package:flutter/material.dart';
import 'package:proyecto_flutter_ia/screens/login_screen.dart';
import 'package:proyecto_flutter_ia/services/evaluacion.dart';
import 'package:proyecto_flutter_ia/services/evaluacion_storage_service.dart';

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

      _filtradas = _evaluaciones!.where((e) {
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

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text('Cerrar Sesión'),
            ],
          ),
          content: const Text(
            '¿Estás seguro que deseas cerrar sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
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
                backgroundColor: Color(0xFFEF4444),
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

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
                    CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Cargando datos...",
                      style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
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
                                Color(0xFF3B82F6),
                                Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Alto Riesgo",
                                "${stats['alto']}",
                                Icons.warning_rounded,
                                Color(0xFFEF4444),
                                Color(0xFFDC2626),
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
                                Color(0xFFF59E0B),
                                Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Bajo Riesgo",
                                "${stats['bajo']}",
                                Icons.check_circle_rounded,
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Gráfico de barras
                        Card(
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF3B82F6,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.bar_chart_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Distribución de Riesgo",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildBarChart(stats),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tabla de datos con filtros
                        Card(
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF3B82F6,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.table_chart_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Datos de Estudiantes",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Barra de búsqueda + filtro de riesgo
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: "Buscar estudiante...",
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Color(0xFF3B82F6),
                                          ),
                                          suffixIcon:
                                              _searchController
                                                      .text
                                                      .isNotEmpty
                                                  ? IconButton(
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      _searchController
                                                          .clear();
                                                    },
                                                  )
                                                  : null,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Color(0xFF3B82F6),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
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
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedRiskFilter,
                                            isExpanded: true,
                                            items:
                                                _riskFilterOptions.map((
                                                  opcion,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: opcion,
                                                    child: Text(
                                                      opcion,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Color(
                                                          0xFF1E293B,
                                                        ),
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
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                else
                                  _buildTabla(),

                                const SizedBox(height: 16),
                                Text(
                                  "Mostrando ${_filtradas?.length ?? 0} de ${_evaluaciones!.length} evaluaciones",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildTabla() {
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
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              color: Color(0xFF3B82F6).withOpacity(0.1),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),
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
                                  color: Colors.grey[200]!,
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
                                        style: const TextStyle(
                                          color: Color(0xFF475569),
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
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
        _buildBar("Alto", stats['alto']!, maxValue, Color(0xFFEF4444)),
        const SizedBox(height: 16),
        _buildBar("Medio", stats['medio']!, maxValue, Color(0xFFF59E0B)),
        const SizedBox(height: 16),
        _buildBar("Bajo", stats['bajo']!, maxValue, Color(0xFF10B981)),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
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