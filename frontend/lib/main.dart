import 'package:flutter/material.dart';
import 'screens/formulario_screen.dart';
import 'screens/resultados_screen.dart';
import 'screens/donaciones_screen.dart';

void main() => runApp(const HuellaCarbonoApp());

class HuellaCarbonoApp extends StatelessWidget {
  const HuellaCarbonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huella de Carbono Estudiantes',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FormularioScreen(),
      routes: {
        '/resultados': (context) => const ResultadosScreen(resultado: ''),
        '/donaciones': (context) => const DonacionesScreen(),
      },
    );
  }
}
