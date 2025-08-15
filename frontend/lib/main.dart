
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resultados_screen.dart';
import 'donaciones_screen.dart';

const String backendUrl = 'https://bookish-space-happiness-wr7x9w7px55h7px-46465.app.github.dev/encuesta';

void main() => runApp(const HuellaCarbonoApp());

class HuellaCarbonoApp extends StatelessWidget {
  const HuellaCarbonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huella de Carbono Estudiantes',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FormularioHuella(),
      routes: {
        '/resultados': (context) => const ResultadosScreen(resultado: ''), // Se sobrescribe al navegar
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
        title: const Text('Datos del estudiante'),
        isActive: _currentStep == 0,
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingrese su nombre' : null,
                onChanged: (v) => nombre = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Carrera'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingrese su carrera' : null,
                onChanged: (v) => carrera = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Semestre'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  int? val = int.tryParse(v ?? '');
                  if (val == null || val < 1 || val > 12) return 'Semestre entre 1 y 12';
                  return null;
                },
                onChanged: (v) => semestre = int.tryParse(v) ?? 1,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  int? val = int.tryParse(v ?? '');
                  if (val == null || val < 15 || val > 100) return 'Edad entre 15 y 100';
                  return null;
                },
                onChanged: (v) => edad = int.tryParse(v) ?? 18,
              ),
            ],
          ),
        ),
      ),
      // --- Paso 1: Desplazamiento ---
      Step(
        title: const Text('Desplazamiento'),
        isActive: _currentStep == 1,
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: transporte,
                items: [
                  'Bus',
                  'Automóvil',
                  'Moto',
                  'Bicicleta',
                  'Caminar',
                  'Otro'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Medio de transporte'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Seleccione un medio de transporte' : null,
                onChanged: (v) => setState(() => transporte = v ?? 'Bus'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Distancia diaria (km)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  double? val = double.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Ingrese una distancia válida';
                  return null;
                },
                onChanged: (v) => distanciaDiaria = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Días de asistencia por semana'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  int? val = int.tryParse(v ?? '');
                  if (val == null || val < 1 || val > 7) return 'Días entre 1 y 7';
                  return null;
                },
                onChanged: (v) => diasAsistencia = int.tryParse(v) ?? 1,
              ),
              SwitchListTile(
                title: const Text('¿Compartes transporte?'),
                value: comparteTransporte,
                onChanged: (v) => setState(() => comparteTransporte = v),
              ),
            ],
          ),
        ),
      ),
      // --- Paso 2: Energía en la universidad ---
      Step(
        title: const Text('Energía en la universidad'),
        isActive: _currentStep == 2,
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Horas en laboratorio/semana'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  double? val = double.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Ingrese un número válido';
                  return null;
                },
                onChanged: (v) => horasLaboratorio = double.tryParse(v) ?? 0,
              ),
              DropdownButtonFormField<String>(
                value: tipoLaboratorio,
                items: [
                  'Cómputo',
                  'Química/Biología',
                  'Electrónica',
                  'Taller de prototipado',
                  'Otro'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Tipo de laboratorio'),
                onChanged: (v) => setState(() => tipoLaboratorio = v ?? 'Cómputo'),
              ),
              SwitchListTile(
                title: const Text('¿Usas equipos de alto consumo?'),
                value: usaEquiposAltoConsumo,
                onChanged: (v) => setState(() => usaEquiposAltoConsumo = v),
              ),
              if (usaEquiposAltoConsumo)
                TextFormField(
                  decoration: const InputDecoration(labelText: '¿Cuáles y cuántas horas?'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingrese detalles de los equipos';
                    return null;
                  },
                  onChanged: (v) => equiposUsados = v,
                ),
            ],
          ),
        ),
      ),
      // --- Paso 3: Energía en casa ---
      Step(
        title: const Text('Energía en casa'),
        isActive: _currentStep == 3,
        content: Form(
          key: _formKeys[3],
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Horas frente al computador/día'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  double? val = double.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Ingrese un número válido';
                  return null;
                },
                onChanged: (v) => horasPcDia = double.tryParse(v) ?? 0,
              ),
              DropdownButtonFormField<String>(
                value: dispositivoPrincipal,
                items: ['Laptop', 'PC de escritorio']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Dispositivo principal'),
                onChanged: (v) => setState(() => dispositivoPrincipal = v ?? 'Laptop'),
              ),
              SwitchListTile(
                title: const Text('¿Consumo extra de electricidad?'),
                value: consumoElectricidadExtra,
                onChanged: (v) => setState(() => consumoElectricidadExtra = v),
              ),
              if (consumoElectricidadExtra)
                TextFormField(
                  decoration: const InputDecoration(labelText: '¿Qué tipo?'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Especifique tipo de consumo';
                    return null;
                  },
                  onChanged: (v) => tipoConsumo = v,
                ),
            ],
          ),
        ),
      ),
      // --- Paso 4: Proyectos universitarios ---
      Step(
        title: const Text('Proyectos universitarios'),
        isActive: _currentStep == 4,
        content: Form(
          key: _formKeys[4],
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tipo de proyectos'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese tipo de proyecto' : null,
                onChanged: (v) => tipoProyectos = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Materiales usados'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese materiales usados' : null,
                onChanged: (v) => materialesUsados = v,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Residuos por proyecto (kg)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  double? val = double.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Ingrese un número válido';
                  return null;
                },
                onChanged: (v) => residuosPorProyecto = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Proyectos por semestre'),
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
      // --- Paso 5: Gestión de residuos ---
      Step(
        title: const Text('Gestión de residuos'),
        isActive: _currentStep == 5,
        content: Form(
          key: _formKeys[5],
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('¿Clasificas tus residuos?'),
                value: clasificaResiduos,
                onChanged: (v) => setState(() => clasificaResiduos = v),
              ),
              DropdownButtonFormField<String>(
                value: porcentajeReciclaje,
                items: [
                  'Nada',
                  'Menos del 25%',
                  '25 – 50%',
                  '50 – 75%',
                  'Más del 75%'
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                decoration: const InputDecoration(labelText: 'Porcentaje reciclaje'),
                onChanged: (v) => setState(() => porcentajeReciclaje = v ?? 'Nada'),
              ),
              SwitchListTile(
                title: const Text('¿Desechas material peligroso?'),
                value: residuosPeligrosos,
                onChanged: (v) => setState(() => residuosPeligrosos = v),
              ),
              if (residuosPeligrosos)
                SwitchListTile(
                  title: const Text('¿Laboratorio gestiona seguro?'),
                  value: laboratorioGestionaSeguro,
                  onChanged: (v) => setState(() => laboratorioGestionaSeguro = v),
                ),
            ],
          ),
        ),
      ),
      // --- Paso 6: Hábitos personales ---
      Step(
        title: const Text('Hábitos personales'),
        isActive: _currentStep == 6,
        content: Form(
          key: _formKeys[6],
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('¿Usas botella reutilizable?'),
                value: usaBotella,
                onChanged: (v) => setState(() => usaBotella = v),
              ),
              SwitchListTile(
                title: const Text('¿Evitas imprimir trabajos?'),
                value: evitaImprimir,
                onChanged: (v) => setState(() => evitaImprimir = v),
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Comidas fuera/semana'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  int? val = int.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Ingrese un número válido';
                  return null;
                },
                onChanged: (v) => comidasFueraSemana = int.tryParse(v) ?? 0,
              ),
              SwitchListTile(
                title: const Text('¿Voluntariado ambiental?'),
                value: voluntariadoAmbiental,
                onChanged: (v) => setState(() => voluntariadoAmbiental = v),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Huella de Carbono Estudiantes')),
      body: Stack(
        children: [
          Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            steps: getSteps(),
            onStepContinue: () {
              if (_currentStep == 6) {
                // Último paso: mostrar botón 'Enviar resultados'
                enviarFormulario();
              } else {
                _continuar();
              }
            },
            controlsBuilder: (context, details) {
              if (_currentStep == 6) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: cargando
                          ? null
                          : () {
                              final formActual = _formKeys[6].currentState;
                              if (formActual != null && formActual.validate()) {
                                enviarFormulario();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Complete todos los campos obligatorios')),
                                );
                              }
                            },
                      child: const Text('Enviar resultados'),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: cargando ? null : details.onStepContinue,
                      child: const Text('Continuar'),
                    ),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: cargando ? null : details.onStepCancel,
                        child: const Text('Atrás'),
                      ),
                  ],
                );
              }
            },
          ),
          if (cargando)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
      bottomNavigationBar: resultado.isNotEmpty
          ? Container(
              color: Colors.green[100],
              padding: const EdgeInsets.all(16),
              child: Text(
                'Huella estimada: $resultado kg CO₂',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
