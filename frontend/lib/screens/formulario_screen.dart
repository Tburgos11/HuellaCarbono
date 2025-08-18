import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resultados_screen.dart';
import 'donaciones_screen.dart';

const String backendUrl = 'http://127.0.0.1:8000/encuesta';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({Key? key}) : super(key: key);

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;
  bool cargando = false;

  // -------------------- Controladores --------------------
  final nombreController = TextEditingController();
  final carreraController = TextEditingController();
  final semestreController = TextEditingController();
  final edadController = TextEditingController();

  String transporte = 'Bus';
  final distanciaController = TextEditingController();
  final diasController = TextEditingController();
  bool comparteTransporte = false;

  final horasLaboratorioController = TextEditingController();
  String tipoLaboratorio = 'Cómputo';
  bool usaEquiposAltoConsumo = false;
  final equiposUsadosController = TextEditingController();

  final horasPcController = TextEditingController();
  String dispositivoPrincipal = 'Laptop';
  bool consumoElectricidadExtra = false;
  final tipoConsumoController = TextEditingController();

  final tipoProyectosController = TextEditingController();
  final materialesUsadosController = TextEditingController();
  final residuosPorProyectoController = TextEditingController();
  final proyectosPorSemestreController = TextEditingController();

  bool clasificaResiduos = false;
  String porcentajeReciclaje = 'Nada';
  bool residuosPeligrosos = false;
  bool laboratorioGestionaSeguro = false;

  bool usaBotella = false;
  bool evitaImprimir = false;
  final comidasFueraController = TextEditingController();
  bool voluntariadoAmbiental = false;

  List<Widget> pages = [];
  final Map<int, bool Function()> validaciones = {};

  @override
  void initState() {
    super.initState();
    _inicializarValidaciones();
    _inicializarPages();
  }

  void _inicializarValidaciones() {
    validaciones[0] = () {
      if (nombreController.text.isEmpty ||
          carreraController.text.isEmpty ||
          semestreController.text.isEmpty ||
          edadController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complete todos los campos del estudiante')));
        return false;
      }
      return true;
    };
    validaciones[1] = () {
      if (distanciaController.text.isEmpty || diasController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complete todos los campos de desplazamiento')));
        return false;
      }
      return true;
    };
    validaciones[2] = () {
      if (usaEquiposAltoConsumo && equiposUsadosController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Especifique los equipos de alto consumo')));
        return false;
      }
      if (horasLaboratorioController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrese las horas de laboratorio por semana')));
        return false;
      }
      return true;
    };
    validaciones[3] = () {
      if (consumoElectricidadExtra && tipoConsumoController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Especifique el tipo de consumo extra')));
        return false;
      }
      if (horasPcController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrese las horas frente al computador/día')));
        return false;
      }
      return true;
    };
    validaciones[4] = () {
      if (tipoProyectosController.text.isEmpty ||
          materialesUsadosController.text.isEmpty ||
          residuosPorProyectoController.text.isEmpty ||
          proyectosPorSemestreController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complete todos los campos de proyectos universitarios')));
        return false;
      }
      return true;
    };
    validaciones[5] = () {
      if (clasificaResiduos && porcentajeReciclaje == 'Nada') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seleccione un porcentaje de reciclaje')));
        return false;
      }
      if (residuosPeligrosos && !laboratorioGestionaSeguro) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Indique si el laboratorio gestiona material peligroso')));
        return false;
      }
      return true;
    };
    validaciones[6] = () {
      if (comidasFueraController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrese la cantidad de comidas fuera por semana')));
        return false;
      }
      return true;
    };
  }

  void _inicializarPages() {
    pages = [
      _buildCard(
        title: 'Datos del Estudiante',
        icon: Icons.person,
        child: Column(
          children: [
            TextFormField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextFormField(controller: carreraController, decoration: const InputDecoration(labelText: 'Carrera')),
            TextFormField(controller: semestreController, decoration: const InputDecoration(labelText: 'Semestre'), keyboardType: TextInputType.number),
            TextFormField(controller: edadController, decoration: const InputDecoration(labelText: 'Edad'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      _buildCard(
        title: 'Desplazamiento',
        icon: Icons.directions_bus,
        child: Column(
          children: [
            DropdownButtonFormField(
              value: transporte,
              decoration: const InputDecoration(labelText: 'Transporte'),
              items: const [
                DropdownMenuItem(value: 'Bus', child: Text('Bus')),
                DropdownMenuItem(value: 'Automóvil', child: Text('Automóvil')),
                DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                DropdownMenuItem(value: 'Bicicleta', child: Text('Bicicleta')),
                DropdownMenuItem(value: 'Caminar', child: Text('Caminar')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (v) => setState(() => transporte = v ?? 'Bus'),
            ),
            TextFormField(controller: distanciaController, decoration: const InputDecoration(labelText: 'Distancia diaria (km)'), keyboardType: TextInputType.number),
            TextFormField(controller: diasController, decoration: const InputDecoration(labelText: 'Días asistencia por semana'), keyboardType: TextInputType.number),
            SwitchListTile(title: const Text('¿Compartes transporte?'), value: comparteTransporte, onChanged: (v) => setState(() => comparteTransporte = v)),
          ],
        ),
      ),
      _buildCard(
        title: 'Energía en la universidad',
        icon: Icons.lightbulb,
        child: Column(
          children: [
            TextFormField(controller: horasLaboratorioController, decoration: const InputDecoration(labelText: 'Horas laboratorio/semana'), keyboardType: TextInputType.number),
            DropdownButtonFormField(
              value: tipoLaboratorio,
              decoration: const InputDecoration(labelText: 'Tipo laboratorio'),
              items: const [
                DropdownMenuItem(value: 'Cómputo', child: Text('Cómputo')),
                DropdownMenuItem(value: 'Química/Biología', child: Text('Química/Biología')),
                DropdownMenuItem(value: 'Electrónica', child: Text('Electrónica')),
                DropdownMenuItem(value: 'Taller de prototipado', child: Text('Taller de prototipado')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (v) => setState(() => tipoLaboratorio = v ?? 'Cómputo'),
            ),
            SwitchListTile(title: const Text('¿Usas equipos de alto consumo?'), value: usaEquiposAltoConsumo, onChanged: (v) => setState(() => usaEquiposAltoConsumo = v)),
            if (usaEquiposAltoConsumo)
              TextFormField(controller: equiposUsadosController, decoration: const InputDecoration(labelText: '¿Cuáles y cuántas horas?')),
          ],
        ),
      ),
      _buildCard(
        title: 'Energía en casa',
        icon: Icons.home,
        child: Column(
          children: [
            TextFormField(controller: horasPcController, decoration: const InputDecoration(labelText: 'Horas frente al computador/día'), keyboardType: TextInputType.number),
            DropdownButtonFormField(
              value: dispositivoPrincipal,
              decoration: const InputDecoration(labelText: 'Dispositivo principal'),
              items: const [
                DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                DropdownMenuItem(value: 'PC de escritorio', child: Text('PC de escritorio')),
              ],
              onChanged: (v) => setState(() => dispositivoPrincipal = v ?? 'Laptop'),
            ),
            SwitchListTile(title: const Text('¿Consumo extra de electricidad?'), value: consumoElectricidadExtra, onChanged: (v) => setState(() => consumoElectricidadExtra = v)),
            if (consumoElectricidadExtra)
              TextFormField(controller: tipoConsumoController, decoration: const InputDecoration(labelText: '¿Qué tipo?')),
          ],
        ),
      ),
      _buildCard(
        title: 'Proyectos universitarios',
        icon: Icons.engineering,
        child: Column(
          children: [
            TextFormField(controller: tipoProyectosController, decoration: const InputDecoration(labelText: 'Tipo de proyectos')),
            TextFormField(controller: materialesUsadosController, decoration: const InputDecoration(labelText: 'Materiales usados')),
            TextFormField(controller: residuosPorProyectoController, decoration: const InputDecoration(labelText: 'Residuos por proyecto (kg)'), keyboardType: TextInputType.number),
            TextFormField(controller: proyectosPorSemestreController, decoration: const InputDecoration(labelText: 'Proyectos por semestre'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      _buildCard(
        title: 'Gestión de residuos',
        icon: Icons.recycling,
        child: Column(
          children: [
            SwitchListTile(title: const Text('¿Clasificas tus residuos?'), value: clasificaResiduos, onChanged: (v) => setState(() => clasificaResiduos = v)),
            DropdownButtonFormField(
              value: porcentajeReciclaje,
              decoration: const InputDecoration(labelText: 'Porcentaje reciclaje'),
              items: const [
                DropdownMenuItem(value: 'Nada', child: Text('Nada')),
                DropdownMenuItem(value: 'Menos del 25%', child: Text('Menos del 25%')),
                DropdownMenuItem(value: '25 – 50%', child: Text('25 – 50%')),
                DropdownMenuItem(value: '50 – 75%', child: Text('50 – 75%')),
                DropdownMenuItem(value: 'Más del 75%', child: Text('Más del 75%')),
              ],
              onChanged: (v) => setState(() => porcentajeReciclaje = v ?? 'Nada'),
            ),
            SwitchListTile(title: const Text('¿Desechas material peligroso?'), value: residuosPeligrosos, onChanged: (v) => setState(() => residuosPeligrosos = v)),
            if (residuosPeligrosos)
              SwitchListTile(title: const Text('¿Laboratorio gestiona seguro?'), value: laboratorioGestionaSeguro, onChanged: (v) => setState(() => laboratorioGestionaSeguro = v)),
          ],
        ),
      ),
      _buildCard(
        title: 'Hábitos personales',
        icon: Icons.favorite,
        child: Column(
          children: [
            SwitchListTile(title: const Text('¿Usas botella reutilizable?'), value: usaBotella, onChanged: (v) => setState(() => usaBotella = v)),
            SwitchListTile(title: const Text('¿Evitas imprimir trabajos?'), value: evitaImprimir, onChanged: (v) => setState(() => evitaImprimir = v)),
            TextFormField(controller: comidasFueraController, decoration: const InputDecoration(labelText: 'Comidas fuera/semana'), keyboardType: TextInputType.number),
            SwitchListTile(title: const Text('¿Voluntariado ambiental?'), value: voluntariadoAmbiental, onChanged: (v) => setState(() => voluntariadoAmbiental = v)),
          ],
        ),
      ),
    ];
  }

  Widget _buildCard({required String title, required Widget child, required IconData icon}) {
    return Center(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.green[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.green[200], child: Icon(icon, color: Colors.white)),
                    const SizedBox(width: 12),
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: SingleChildScrollView(child: child)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _siguientePagina,
                      child: Text(currentPage == pages.length - 1 ? 'Enviar' : 'Siguiente'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _siguientePagina() {
    final valida = validaciones[currentPage];
    if (valida != null && !valida()) return; // no avanza si falla la validación
    if (currentPage == pages.length - 1) {
      _validarYEnviar();
    } else {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _validarYEnviar() async {
    setState(() => cargando = true);
    final body = {
      "nombre": nombreController.text,
      "carrera": carreraController.text,
      "semestre": int.tryParse(semestreController.text) ?? 1,
      "edad": int.tryParse(edadController.text) ?? 18,
      "transporte": transporte,
      "distancia_diaria_km": double.tryParse(distanciaController.text) ?? 0,
      "dias_asistencia": int.tryParse(diasController.text) ?? 1,
    };
    try {
      final response = await http.post(Uri.parse(backendUrl), headers: {'Content-Type': 'application/json'}, body: json.encode(body));
      setState(() => cargando = false);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resultado = data["emisiones_estimadas_kgCO2"].toString();
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultadosScreen(resultado: resultado)))
            .then((_) => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonacionesScreen())));
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(title: const Text('Error'), content: const Text('Error al enviar formulario. Intente nuevamente.')),
        );
      }
    } catch (_) {
      setState(() => cargando = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(title: const Text('Error de conexión'), content: const Text('No se pudo conectar al servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Huella de Carbono Estudiantes'), backgroundColor: Colors.green),
      body: Row(
        children: [
          // Barra lateral con bolitas
          Container(
            width: 60,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPage = index;
                      pageController.jumpToPage(index);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentPage == index ? Colors.green : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
          ),
          // Página principal
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => currentPage = i),
                  children: pages,
                ),
                if (cargando)
                  Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
