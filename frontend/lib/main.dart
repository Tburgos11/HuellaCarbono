import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const HuellaCarbonoApp());

class HuellaCarbonoApp extends StatelessWidget {
  const HuellaCarbonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huella de Carbono Estudiantes',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FormularioHuella(),
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
  final _formKey = GlobalKey<FormState>();

  // 1. Datos estudiante
  String nombre = '';
  String carrera = '';
  int semestre = 1;
  int edad = 18;

  // 2. Transporte
  String transporte = 'Bus';
  double distanciaDiaria = 0;
  int diasAsistencia = 1;
  bool comparteTransporte = false;

  // 3. Laboratorio
  double horasLaboratorio = 0;
  String tipoLaboratorio = 'Cómputo';
  bool usaEquiposAltoConsumo = false;
  String equiposUsados = '';

  // 4. Energía en casa
  double horasPcDia = 0;
  String dispositivoPrincipal = 'Laptop';
  bool consumoElectricidadExtra = false;
  String tipoConsumo = '';

  // 5. Proyectos
  String tipoProyectos = '';
  String materialesUsados = '';
  double residuosPorProyecto = 0;
  int proyectosPorSemestre = 1;

  // 6. Residuos
  bool clasificaResiduos = false;
  String porcentajeReciclaje = 'Nada';
  bool residuosPeligrosos = false;
  bool laboratorioGestionaSeguro = false;

  // 7. Hábitos
  bool usaBotella = false;
  bool evitaImprimir = false;
  int comidasFueraSemana = 0;
  bool voluntariadoAmbiental = false;

  String resultado = '';

  List<Step> getSteps() {
    return [
      Step(
        title: const Text('Datos del estudiante'),
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
              onChanged: (v) => nombre = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Carrera'),
              onChanged: (v) => carrera = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Semestre'),
              keyboardType: TextInputType.number,
              onChanged: (v) => semestre = int.tryParse(v) ?? 1,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              onChanged: (v) => edad = int.tryParse(v) ?? 18,
            ),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text('Desplazamiento'),
        content: Column(
          children: [
            DropdownButtonFormField<String>(
              value: transporte,
              items: [
                'Bus','Automóvil','Moto','Bicicleta','Caminar','Otro'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => transporte = v ?? 'Bus'),
              decoration: const InputDecoration(labelText: 'Medio de transporte'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Distancia diaria (km)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => distanciaDiaria = double.tryParse(v) ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Días de asistencia por semana'),
              keyboardType: TextInputType.number,
              onChanged: (v) => diasAsistencia = int.tryParse(v) ?? 1,
            ),
            SwitchListTile(
              title: const Text('¿Compartes transporte?'),
              value: comparteTransporte,
              onChanged: (v) => setState(() => comparteTransporte = v),
            ),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text('Energía en la universidad'),
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Horas en laboratorio/semana'),
              keyboardType: TextInputType.number,
              onChanged: (v) => horasLaboratorio = double.tryParse(v) ?? 0,
            ),
            DropdownButtonFormField<String>(
              value: tipoLaboratorio,
              items: [
                'Cómputo','Química/Biología','Electrónica','Taller de prototipado','Otro'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => tipoLaboratorio = v ?? 'Cómputo'),
              decoration: const InputDecoration(labelText: 'Tipo de laboratorio'),
            ),
            SwitchListTile(
              title: const Text('¿Usas equipos de alto consumo?'),
              value: usaEquiposAltoConsumo,
              onChanged: (v) => setState(() => usaEquiposAltoConsumo = v),
            ),
            if (usaEquiposAltoConsumo)
              TextFormField(
                decoration: const InputDecoration(labelText: '¿Cuáles y cuántas horas?'),
                onChanged: (v) => equiposUsados = v,
              ),
          ],
        ),
        isActive: _currentStep == 2,
      ),
      Step(
        title: const Text('Energía en casa'),
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Horas frente al computador/día'),
              keyboardType: TextInputType.number,
              onChanged: (v) => horasPcDia = double.tryParse(v) ?? 0,
            ),
            DropdownButtonFormField<String>(
              value: dispositivoPrincipal,
              items: ['Laptop','PC de escritorio']
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dispositivoPrincipal = v ?? 'Laptop'),
              decoration: const InputDecoration(labelText: 'Dispositivo principal'),
            ),
            SwitchListTile(
              title: const Text('¿Consumo extra de electricidad?'),
              value: consumoElectricidadExtra,
              onChanged: (v) => setState(() => consumoElectricidadExtra = v),
            ),
            if (consumoElectricidadExtra)
              TextFormField(
                decoration: const InputDecoration(labelText: '¿Qué tipo?'),
                onChanged: (v) => tipoConsumo = v,
              ),
          ],
        ),
        isActive: _currentStep == 3,
      ),
      Step(
        title: const Text('Proyectos universitarios'),
        content: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tipo de proyectos'),
              onChanged: (v) => tipoProyectos = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Materiales usados'),
              onChanged: (v) => materialesUsados = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Residuos por proyecto (kg)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => residuosPorProyecto = double.tryParse(v) ?? 0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Proyectos por semestre'),
              keyboardType: TextInputType.number,
              onChanged: (v) => proyectosPorSemestre = int.tryParse(v) ?? 1,
            ),
          ],
        ),
        isActive: _currentStep == 4,
      ),
      Step(
        title: const Text('Gestión de residuos'),
        content: Column(
          children: [
            SwitchListTile(
              title: const Text('¿Clasificas tus residuos?'),
              value: clasificaResiduos,
              onChanged: (v) => setState(() => clasificaResiduos = v),
            ),
            DropdownButtonFormField<String>(
              value: porcentajeReciclaje,
              items: [
                'Nada','Menos del 25%','25 – 50%','50 – 75%','Más del 75%'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => porcentajeReciclaje = v ?? 'Nada'),
              decoration: const InputDecoration(labelText: 'Porcentaje reciclaje'),
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
        isActive: _currentStep == 5,
      ),
      Step(
        title: const Text('Hábitos personales'),
        content: Column(
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
              decoration: const InputDecoration(labelText: 'Comidas fuera/semana'),
              keyboardType: TextInputType.number,
              onChanged: (v) => comidasFueraSemana = int.tryParse(v) ?? 0,
            ),
            SwitchListTile(
              title: const Text('¿Voluntariado ambiental?'),
              value: voluntariadoAmbiental,
              onChanged: (v) => setState(() => voluntariadoAmbiental = v),
            ),
          ],
        ),
        isActive: _currentStep == 6,
      ),
    ];
  }

  void enviarFormulario() async {
    final url = Uri.parse('http://localhost:8000/encuesta');
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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    setState(() {
      resultado = response.statusCode == 200
          ? json.decode(response.body)["emisiones_estimadas_kgCO2"].toString()
          : 'Error al enviar formulario';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Huella de Carbono Estudiantes')),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          steps: getSteps(),
          onStepContinue: () {
            if (_currentStep < getSteps().length - 1) {
              setState(() => _currentStep++);
            } else {
              enviarFormulario();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
        ),
      ),
      bottomNavigationBar: resultado.isNotEmpty
          ? Container(
              color: Colors.green[100],
              padding: const EdgeInsets.all(16),
              child: Text(
                'Huella de carbono estimada: $resultado kg CO₂',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
