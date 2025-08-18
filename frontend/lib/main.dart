import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resultados_screen.dart';
import 'donaciones_screen.dart';

const String backendUrl = 'http://127.0.0.1:8000/encuesta';

void main() => runApp(const HuellaCarbonoApp());

class HuellaCarbonoApp extends StatelessWidget {
  const HuellaCarbonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huella de Carbono Estudiantes',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Verde oscuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Verde principal
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.green.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.green.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          filled: true,
          fillColor: Colors.green.shade50,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Verde muy claro
      ),
      home: const FormularioHuella(),
      routes: {
        '/resultados': (context) =>
            const ResultadosScreen(resultado: ''), // Se sobrescribe al navegar
        '/donaciones': (context) => const DonacionesScreen(),
      },
    );
  }
}

class FormularioHuella extends StatefulWidget {
  const FormularioHuella({super.key});

  @override
  State<FormularioHuella> createState() => _FormularioHuellaState();
}

class _FormularioHuellaState extends State<FormularioHuella> {
  int _currentStep = 0;
  bool cargando = false;
  String resultado = '';

  final List<GlobalKey<FormState>> _formKeys =
      List.generate(7, (_) => GlobalKey<FormState>());

  // ------- VARIABLES -------
  String nombre = '';
  String carrera = '';
  int semestre = 1;
  int edad = 18;

  String transporte = 'Bus';
  double distanciaDiaria = 0;
  int diasAsistencia = 1;
  bool comparteTransporte = false;

  double horasLaboratorio = 0;
  String tipoLaboratorio = 'Cómputo';
  bool usaEquiposAltoConsumo = false;
  String equiposUsados = '';

  double horasPcDia = 0;
  String dispositivoPrincipal = 'Laptop';
  bool consumoElectricidadExtra = false;
  String tipoConsumo = '';

  String tipoProyectos = '';
  String materialesUsados = '';
  double residuosPorProyecto = 0;
  int proyectosPorSemestre = 1;

  bool clasificaResiduos = false;
  String porcentajeReciclaje = 'Nada';
  bool residuosPeligrosos = false;
  bool laboratorioGestionaSeguro = false;

  bool usaBotella = false;
  bool evitaImprimir = false;
  int comidasFueraSemana = 0;
  bool voluntariadoAmbiental = false;

  // ------ FUNCIONES ------
  void _continuar() {
    final formActual = _formKeys[_currentStep].currentState;
    if (formActual != null && formActual.validate()) {
      if (_currentStep < 6) {
        setState(() => _currentStep++);
      } else {
        enviarFormulario();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos obligatorios')),
      );
    }
  }

  Future<void> enviarFormulario() async {
    setState(() => cargando = true);

    final url = Uri.parse(backendUrl);
    final body = {
      "nombre": nombre,
      "carrera": carrera,
      "semestre": semestre,
      "edad": edad,
      "transporte": transporte,
      "distancia_diaria_km": distanciaDiaria,
      "dias_asistencia": diasAsistencia,
      "comparte_transporte": comparteTransporte,
      "horas_laboratorio": horasLaboratorio,
      "tipo_laboratorio": tipoLaboratorio,
      "usa_equipos_alto_consumo": usaEquiposAltoConsumo,
      "equipos_usados": equiposUsados,
      "horas_pc_dia": horasPcDia,
      "dispositivo_principal": dispositivoPrincipal,
      "consumo_electricidad_extra": consumoElectricidadExtra,
      "tipo_consumo": tipoConsumo,
      "tipo_proyectos": tipoProyectos,
      "materiales_usados": materialesUsados,
      "residuos_por_proyecto_kg": residuosPorProyecto,
      "proyectos_por_semestre": proyectosPorSemestre,
      "clasifica_residuos": clasificaResiduos,
      "porcentaje_reciclaje": porcentajeReciclaje,
      "residuos_peligrosos": residuosPeligrosos,
      "laboratorio_gestiona_seguro": laboratorioGestionaSeguro,
      "usa_botella": usaBotella,
      "evita_imprimir": evitaImprimir,
      "comidas_fuera_semana": comidasFueraSemana,
      "voluntariado_ambiental": voluntariadoAmbiental,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      setState(() => cargando = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        resultado = data["emisiones_estimadas_kgCO2"].toString();
        // Navegar a la pantalla de resultados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultadosScreen(resultado: resultado),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Error'),
            content: Text('Error al enviar formulario. Intente nuevamente.'),
          ),
        );
      }
    } catch (e) {
      setState(() => cargando = false);
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Error de conexión'),
          content: Text('No se pudo conectar al servidor.'),
        ),
      );
    }
  }

  List<Step> getSteps() {
    return [
      // --- Paso 0: Datos del estudiante ---
      Step(
        title: Text(
          '👤 Datos del estudiante',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 0,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[0],
            child: Column(
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese su nombre'
                      : null,
                  onChanged: (v) => nombre = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    prefixIcon: Icon(Icons.school),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese su carrera'
                      : null,
                  onChanged: (v) => carrera = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Semestre',
                    prefixIcon: Icon(Icons.calendar_today),
                    helperText: 'Ingrese un número entre 1 y 12',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    int? val = int.tryParse(v ?? '');
                    if (val == null || val < 1 || val > 12)
                      return 'Semestre entre 1 y 12';
                    return null;
                  },
                  onChanged: (v) => semestre = int.tryParse(v) ?? 1,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    prefixIcon: Icon(Icons.cake),
                    helperText: 'Ingrese su edad',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    int? val = int.tryParse(v ?? '');
                    if (val == null || val < 15 || val > 100)
                      return 'Edad entre 15 y 100';
                    return null;
                  },
                  onChanged: (v) => edad = int.tryParse(v) ?? 18,
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Paso 1: Desplazamiento ---
      Step(
        title: Text(
          '🚌 Desplazamiento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 1,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[1],
            child: Column(
              children: [
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: transporte,
                  items: [
                    {'value': 'Bus', 'icon': Icons.directions_bus},
                    {'value': 'Automóvil', 'icon': Icons.directions_car},
                    {'value': 'Moto', 'icon': Icons.motorcycle},
                    {'value': 'Bicicleta', 'icon': Icons.pedal_bike},
                    {'value': 'Caminar', 'icon': Icons.directions_walk},
                    {'value': 'Otro', 'icon': Icons.more_horiz},
                  ]
                      .map((item) => DropdownMenuItem(
                            value: item['value'] as String,
                            child: Row(
                              children: [
                                Icon(item['icon'] as IconData,
                                    size: 20, color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Text(item['value'] as String),
                              ],
                            ),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Medio de transporte',
                    prefixIcon: Icon(Icons.commute),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Seleccione un medio de transporte'
                      : null,
                  onChanged: (v) => setState(() => transporte = v ?? 'Bus'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Distancia diaria (km)',
                    prefixIcon: Icon(Icons.straighten),
                    helperText: 'Distancia total de ida y vuelta',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    double? val = double.tryParse(v ?? '');
                    if (val == null || val < 0)
                      return 'Ingrese una distancia válida';
                    return null;
                  },
                  onChanged: (v) => distanciaDiaria = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Días de asistencia por semana',
                    prefixIcon: Icon(Icons.event_available),
                    helperText: 'Días que asiste a la universidad',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    int? val = int.tryParse(v ?? '');
                    if (val == null || val < 1 || val > 7)
                      return 'Días entre 1 y 7';
                    return null;
                  },
                  onChanged: (v) => diasAsistencia = int.tryParse(v) ?? 1,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Compartes transporte?'),
                    subtitle: const Text('Viaja con otras personas'),
                    value: comparteTransporte,
                    onChanged: (v) => setState(() => comparteTransporte = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Paso 2: Energía en la universidad ---
      Step(
        title: Text(
          '⚡ Energía en la universidad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 2,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[2],
            child: Column(
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Horas en laboratorio por semana',
                    prefixIcon: Icon(Icons.access_time),
                    helperText: 'Tiempo promedio en laboratorios',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    double? val = double.tryParse(v ?? '');
                    if (val == null || val < 0)
                      return 'Ingrese un número válido';
                    return null;
                  },
                  onChanged: (v) => horasLaboratorio = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tipoLaboratorio,
                  items: [
                    {'value': 'Cómputo', 'icon': Icons.computer},
                    {'value': 'Química/Biología', 'icon': Icons.science},
                    {'value': 'Electrónica', 'icon': Icons.electrical_services},
                    {'value': 'Taller de prototipado', 'icon': Icons.build},
                    {'value': 'Otro', 'icon': Icons.more_horiz},
                  ]
                      .map((item) => DropdownMenuItem(
                            value: item['value'] as String,
                            child: Row(
                              children: [
                                Icon(item['icon'] as IconData,
                                    size: 20, color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Text(item['value'] as String),
                              ],
                            ),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de laboratorio más usado',
                    prefixIcon: Icon(Icons.business),
                  ),
                  onChanged: (v) =>
                      setState(() => tipoLaboratorio = v ?? 'Cómputo'),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Usas equipos de alto consumo?'),
                    subtitle: const Text('Servidores, equipos especializados'),
                    value: usaEquiposAltoConsumo,
                    onChanged: (v) => setState(() => usaEquiposAltoConsumo = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                if (usaEquiposAltoConsumo)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '¿Cuáles equipos y cuántas horas?',
                      prefixIcon: Icon(Icons.settings),
                      helperText: 'Especifique equipos y tiempo de uso',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Ingrese detalles de los equipos';
                      return null;
                    },
                    onChanged: (v) => equiposUsados = v,
                  ),
              ],
            ),
          ),
        ),
      ),
      // --- Paso 3: Energía en casa ---
      Step(
        title: Text('🏠 Energía en casa', 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 3,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[3],
            child: Column(
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Horas frente al computador por día',
                    prefixIcon: Icon(Icons.computer),
                    helperText: 'Tiempo promedio diario',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    double? val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Ingrese un número válido';
                    return null;
                  },
                  onChanged: (v) => horasPcDia = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: dispositivoPrincipal,
                  items: [
                    {'value': 'Laptop', 'icon': Icons.laptop},
                    {'value': 'PC de escritorio', 'icon': Icons.desktop_windows},
                  ].map((item) => DropdownMenuItem(
                    value: item['value'] as String,
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 20, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(item['value'] as String),
                      ],
                    ),
                  )).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Dispositivo principal',
                    prefixIcon: Icon(Icons.devices),
                  ),
                  onChanged: (v) =>
                      setState(() => dispositivoPrincipal = v ?? 'Laptop'),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Consumo extra de electricidad?'),
                    subtitle: const Text('Aires acondicionados, calefactores, etc.'),
                    value: consumoElectricidadExtra,
                    onChanged: (v) => setState(() => consumoElectricidadExtra = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                if (consumoElectricidadExtra)
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '¿Qué tipo de consumo extra?',
                      prefixIcon: Icon(Icons.electrical_services),
                      helperText: 'Especifique los equipos adicionales',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Especifique tipo de consumo';
                      return null;
                    },
                    onChanged: (v) => tipoConsumo = v,
                  ),
              ],
            ),
          ),
        ),
      ),
      // --- Paso 4: Proyectos universitarios ---
      Step(
        title: Text('📚 Proyectos universitarios', 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 4,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[4],
            child: Column(
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de proyectos que realizas',
                    prefixIcon: Icon(Icons.assignment),
                    helperText: 'Ej: Software, hardware, investigación',
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Ingrese tipo de proyecto'
                      : null,
                  onChanged: (v) => tipoProyectos = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Materiales principales utilizados',
                    prefixIcon: Icon(Icons.inventory),
                    helperText: 'Ej: Plástico, metal, componentes electrónicos',
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Ingrese materiales usados'
                      : null,
                  onChanged: (v) => materialesUsados = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Residuos por proyecto (kg)',
                    prefixIcon: Icon(Icons.delete_outline),
                    helperText: 'Cantidad aproximada de desechos generados',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    double? val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Ingrese un número válido';
                    return null;
                  },
                  onChanged: (v) => residuosPorProyecto = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Proyectos por semestre',
                    prefixIcon: Icon(Icons.calendar_month),
                    helperText: 'Número de proyectos que realizas por semestre',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    int? val = int.tryParse(v ?? '');
                    if (val == null || val < 1) return 'Ingrese un número válido';
                    return null;
                  },
                  onChanged: (v) => proyectosPorSemestre = int.tryParse(v) ?? 1,
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Paso 5: Gestión de residuos ---
      Step(
        title: Text('♻️ Gestión de residuos', 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 5,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[5],
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Clasificas tus residuos?'),
                    subtitle: const Text('Separas orgánico, reciclable, etc.'),
                    value: clasificaResiduos,
                    onChanged: (v) => setState(() => clasificaResiduos = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: porcentajeReciclaje,
                  items: [
                    {'value': 'Nada', 'icon': Icons.close},
                    {'value': 'Menos del 25%', 'icon': Icons.recycling},
                    {'value': '25 – 50%', 'icon': Icons.recycling},
                    {'value': '50 – 75%', 'icon': Icons.recycling},
                    {'value': 'Más del 75%', 'icon': Icons.eco},
                  ].map((item) => DropdownMenuItem(
                    value: item['value'] as String,
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 20, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(item['value'] as String),
                      ],
                    ),
                  )).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Porcentaje de reciclaje',
                    prefixIcon: Icon(Icons.percent),
                    helperText: 'Qué tanto reciclas de tus residuos',
                  ),
                  onChanged: (v) =>
                      setState(() => porcentajeReciclaje = v ?? 'Nada'),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Desechas material peligroso?'),
                    subtitle: const Text('Químicos, baterías, electrónicos'),
                    value: residuosPeligrosos,
                    onChanged: (v) => setState(() => residuosPeligrosos = v),
                    activeColor: Colors.orange.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                if (residuosPeligrosos)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: SwitchListTile(
                      title: const Text('¿El laboratorio gestiona de forma segura?'),
                      subtitle: const Text('Protocolo adecuado para desechos peligrosos'),
                      value: laboratorioGestionaSeguro,
                      onChanged: (v) =>
                          setState(() => laboratorioGestionaSeguro = v),
                      activeColor: Colors.blue.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      // --- Paso 6: Hábitos personales ---
      Step(
        title: Text('🌱 Hábitos personales', 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        isActive: _currentStep == 6,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKeys[6],
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Usas botella reutilizable?'),
                    subtitle: const Text('Reduces el uso de plástico desechable'),
                    value: usaBotella,
                    onChanged: (v) => setState(() => usaBotella = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Evitas imprimir trabajos?'),
                    subtitle: const Text('Prefieres versiones digitales'),
                    value: evitaImprimir,
                    onChanged: (v) => setState(() => evitaImprimir = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Comidas fuera por semana',
                    prefixIcon: Icon(Icons.restaurant),
                    helperText: 'Número de veces que comes fuera de casa',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    int? val = int.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Ingrese un número válido';
                    return null;
                  },
                  onChanged: (v) => comidasFueraSemana = int.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: SwitchListTile(
                    title: const Text('¿Participas en voluntariado ambiental?'),
                    subtitle: const Text('Actividades de conservación o limpieza'),
                    value: voluntariadoAmbiental,
                    onChanged: (v) => setState(() => voluntariadoAmbiental = v),
                    activeColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Huella de Carbono Estudiantes'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Indicador de progreso
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Paso ${_currentStep + 1} de 7',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentStep + 1) / 7,
                          backgroundColor: Colors.green.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade600,
                          ),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                  // Contenido del stepper
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: const Color(0xFF4CAF50),
                            ),
                      ),
                      child: Stepper(
                        type: StepperType.vertical,
                        currentStep: _currentStep,
                        steps: getSteps(),
                        onStepContinue: () {
                          if (_currentStep == 6) {
                            enviarFormulario();
                          } else {
                            _continuar();
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() => _currentStep--);
                          }
                        },
                        controlsBuilder: (context, details) {
                          return Container(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: cargando
                                        ? null
                                        : (_currentStep == 6
                                            ? () {
                                                final formActual =
                                                    _formKeys[6].currentState;
                                                if (formActual != null &&
                                                    formActual.validate()) {
                                                  enviarFormulario();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                          'Complete todos los campos obligatorios'),
                                                      backgroundColor: Colors
                                                          .orange.shade600,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            : details.onStepContinue),
                                    icon: Icon(_currentStep == 6
                                        ? Icons.send
                                        : Icons.arrow_forward),
                                    label: Text(_currentStep == 6
                                        ? 'Enviar Resultados'
                                        : 'Continuar'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_currentStep > 0)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.green.shade300),
                                    ),
                                    child: TextButton.icon(
                                      onPressed: cargando
                                          ? null
                                          : details.onStepCancel,
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Atrás'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.green.shade700,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (cargando)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Calculando tu huella de carbono...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
      bottomNavigationBar: resultado.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade200],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Huella estimada: $resultado kg CO₂',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
