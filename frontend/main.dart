import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(HuellaCarbonoApp());
}

class HuellaCarbonoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huella de Carbono Estudiantes',
      theme: ThemeData(primarySwatch: Colors.green),
      home: FormularioHuella(),
    );
  }
}

class FormularioHuella extends StatefulWidget {
  @override
  _FormularioHuellaState createState() => _FormularioHuellaState();
}

class _FormularioHuellaState extends State<FormularioHuella> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Variables para cada sección
  // 1. Datos del estudiante
  String nombre = '';
  String carrera = '';
  int semestre = 1;
  int edad = 18;

  // 2. Desplazamiento
  String transporte = 'Bus';
  double distanciaDiaria = 0;
  int diasAsistencia = 1;
  bool comparteTransporte = false;

  // 3. Uso de energía en la universidad
  double horasLaboratorio = 0;
  String tipoLaboratorio = 'Cómputo';
  bool usaEquiposAltoConsumo = false;
  String equiposUsados = '';

  // 4. Uso de energía en casa
  double horasPcDia = 0;
  String dispositivoPrincipal = 'Laptop';
  bool consumoElectricidadExtra = false;
  String tipoConsumo = '';

  // 5. Proyectos universitarios
  String tipoProyectos = '';
  String materialesUsados = '';
  double residuosPorProyecto = 0;
  int proyectosPorSemestre = 1;

  // 6. Gestión de residuos
  bool clasificaResiduos = false;
  String porcentajeReciclaje = 'Nada';
  bool residuosPeligrosos = false;
  bool laboratorioGestionaSeguro = false;

  // 7. Hábitos personales sostenibles
  bool usaBotella = false;
  bool evitaImprimir = false;
  int comidasFueraSemana = 0;
  bool voluntariadoAmbiental = false;

  // Resultado
  String resultado = '';

  List<Step> getSteps() {
    return [
      // 1. Datos del estudiante
      Step(
        title: Text('Datos del estudiante'),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nombre'),
              onChanged: (v) => nombre = v,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Carrera'),
              onChanged: (v) => carrera = v,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Semestre'),
              keyboardType: TextInputType.number,
              onChanged: (v) => semestre = int.tryParse(v) ?? 1,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              onChanged: (v) => edad = int.tryParse(v) ?? 18,
            ),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      // 2. Desplazamiento
      Step(
        title: Text('Desplazamiento'),
        content: Column(
          children: [
            DropdownButtonFormField<String>(
              value: transporte,
              items: [
                'Bus', 'Automóvil', 'Moto', 'Bicicleta', 'Caminar', 'Otro'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => transporte = v ?? 'Bus'),
              decoration: InputDecoration(labelText: 'Medio de transporte'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Distancia diaria (km)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => distanciaDiaria = double.tryParse(v) ?? 0,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Días de asistencia por semana'),
              keyboardType: TextInputType.number,
              onChanged: (v) => diasAsistencia = int.tryParse(v) ?? 1,
            ),
            SwitchListTile(
              title: Text('¿Compartes transporte?'),
              value: comparteTransporte,
              onChanged: (v) => setState(() => comparteTransporte = v),
            ),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      // 3. Uso de energía en la universidad
      Step(
        title: Text('Energía en la universidad'),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Horas en laboratorio/semana'),
              keyboardType: TextInputType.number,
              onChanged: (v) => horasLaboratorio = double.tryParse(v) ?? 0,
            ),
            DropdownButtonFormField<String>(
              value: tipoLaboratorio,
              items: [
                'Cómputo', 'Química/Biología', 'Electrónica', 'Taller de prototipado', 'Otro'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => tipoLaboratorio = v ?? 'Cómputo'),
              decoration: InputDecoration(labelText: 'Tipo de laboratorio'),
            ),
            SwitchListTile(
              title: Text('¿Usas equipos de alto consumo?'),
              value: usaEquiposAltoConsumo,
              onChanged: (v) => setState(() => usaEquiposAltoConsumo = v),
            ),
            if (usaEquiposAltoConsumo)
              TextFormField(
                decoration: InputDecoration(labelText: '¿Cuáles y cuántas horas?'),
                onChanged: (v) => equiposUsados = v,
              ),
          ],
        ),
        isActive: _currentStep == 2,
      ),
      // 4. Energía en casa
      Step(
        title: Text('Energía en casa'),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Horas frente al computador/día'),
              keyboardType: TextInputType.number,
              onChanged: (v) => horasPcDia = double.tryParse(v) ?? 0,
            ),
            DropdownButtonFormField<String>(
              value: dispositivoPrincipal,
              items: ['Laptop', 'PC de escritorio']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dispositivoPrincipal = v ?? 'Laptop'),
              decoration: InputDecoration(labelText: 'Dispositivo principal'),
            ),
            SwitchListTile(
              title: Text('¿Consumo extra de electricidad?'),
              value: consumoElectricidadExtra,
              onChanged: (v) => setState(() => consumoElectricidadExtra = v),
            ),
            if (consumoElectricidadExtra)
              TextFormField(
                decoration: InputDecoration(labelText: '¿Qué tipo?'),
                onChanged: (v) => tipoConsumo = v,
              ),
          ],
        ),
        isActive: _currentStep == 3,
      ),
      // 5. Proyectos universitarios
      Step(
        title: Text('Proyectos universitarios'),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Tipo de proyectos'),
              onChanged: (v) => tipoProyectos = v,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Materiales usados'),
              onChanged: (v) => materialesUsados = v,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Residuos por proyecto (kg)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => residuosPorProyecto = double.tryParse(v) ?? 0,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Proyectos por semestre'),
              keyboardType: TextInputType.number,
              onChanged: (v) => proyectosPorSemestre = int.tryParse(v) ?? 1,
            ),
          ],
        ),
        isActive: _currentStep == 4,
      ),
      // 6. Gestión de residuos
      Step(
        title: Text('Gestión de residuos'),
        content: Column(
          children: [
            SwitchListTile(
              title: Text('¿Clasificas tus residuos?'),
              value: clasificaResiduos,
              onChanged: (v) => setState(() => clasificaResiduos = v),
            ),
            DropdownButtonFormField<String>(
              value: porcentajeReciclaje,
              items: [
                'Nada', 'Menos del 25%', '25 – 50%', '50 – 75%', 'Más del 75%'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => porcentajeReciclaje = v ?? 'Nada'),
              decoration: InputDecoration(labelText: 'Porcentaje reciclaje'),
            ),
            SwitchListTile(
              title: Text('¿Desechas material peligroso?'),
              value: residuosPeligrosos,
              onChanged: (v) => setState(() => residuosPeligrosos = v),
            ),
            if (residuosPeligrosos)
              SwitchListTile(
                title: Text('¿Laboratorio gestiona seguro?'),
                value: laboratorioGestionaSeguro,
                onChanged: (v) => setState(() => laboratorioGestionaSeguro = v),
              ),
          ],
        ),
        isActive: _currentStep == 5,
      ),
      // 7. Hábitos personales
      Step(
        title: Text('Hábitos personales'),
        content: Column(
          children: [
            SwitchListTile(
              title: Text('¿Usas botella reutilizable?'),
              value: usaBotella,
              onChanged: (v) => setState(() => usaBotella = v),
            ),
            SwitchListTile(
              title: Text('¿Evitas imprimir trabajos?'),
              value: evitaImprimir,
              onChanged: (v) => setState(() => evitaImprimir = v),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Comidas fuera/semana'),
              keyboardType: TextInputType.number,
              onChanged: (v) => comidasFueraSemana = int.tryParse(v) ?? 0,
            ),
            SwitchListTile(
              title: Text('¿Voluntariado ambiental?'),
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
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));
    if (response.statusCode == 200) {
      setState(() {
        resultado = json.decode(response.body)["emisiones_estimadas_kgCO2"].toString();
      });
    } else {
      setState(() {
        resultado = 'Error al enviar formulario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Huella de Carbono Estudiantes')),
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
              padding: EdgeInsets.all(16),
              child: Text(
                'Huella de carbono estimada: $resultado kg CO₂',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
