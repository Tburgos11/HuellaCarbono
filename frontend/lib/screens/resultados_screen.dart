import 'package:flutter/material.dart';

class ResultadosScreen extends StatelessWidget {
  final String resultado;
  const ResultadosScreen({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados de Huella de Carbono')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tu huella de carbono estimada es:',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              '$resultado kg CO₂',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/donaciones');
              },
              child: const Text('Quiero hacer una donación'),
            ),
          ],
        ),
      ),
    );
  }
}
