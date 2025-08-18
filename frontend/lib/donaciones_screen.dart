import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonacionesScreen extends StatelessWidget {
  const DonacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donaciones Ambientales')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '¡Gracias por tu interés en donar! Estas fundaciones trabajan activamente en la protección del medio ambiente:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFoundationCard(
                    'EcoVerde Ecuador',
                    'Organización dedicada a la reforestación de bosques nativos y la protección de especies en peligro de extinción.',
                    Colors.green,
                  ),
                  _buildFoundationCard(
                    'Mares Limpios',
                    'Fundación enfocada en la limpieza de océanos y la reducción de plásticos en ecosistemas marinos.',
                    Colors.blue,
                  ),
                  _buildFoundationCard(
                    'Energía Sostenible',
                    'Promueve el uso de energías renovables en comunidades rurales y proyectos de eficiencia energética.',
                    Colors.orange,
                  ),
                  _buildFoundationCard(
                    'Carbono Neutral',
                    'Especializada en proyectos de captura de carbono y compensación de emisiones mediante tecnologías verdes.',
                    Colors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundationCard(String name, String description, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    _showDonationDialog(context, name, color);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('¡Quiero donar!'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationDialog(BuildContext context, String foundationName, Color color) {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Donar a $foundationName',
            style: TextStyle(color: color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Para proceder con tu donación, por favor ingresa tu correo electrónico:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty && 
                    emailController.text.contains('@')) {
                  Navigator.of(context).pop();
                  await _saveDonationToBackend(emailController.text, foundationName);
                  _showConfirmationMessage(context, foundationName, color);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa un correo electrónico válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationMessage(BuildContext context, String foundationName, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          content: Text(
            'Gracias por formar parte del cambio, $foundationName se comunicará contigo por correo',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('¡Genial!'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDonationToBackend(String email, String foundationName) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/donacion'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'foundation_name': foundationName,
        }),
      );

      if (response.statusCode == 200) {
        print('Donación guardada exitosamente');
      } else {
        print('Error al guardar la donación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }
}
