import 'package:flutter/material.dart';

class TarjetaFormulario extends StatelessWidget {
  final String titulo;
  final Color color;
  final Widget child;
  final VoidCallback onSiguiente;

  const TarjetaFormulario({
    super.key,
    required this.titulo,
    required this.color,
    required this.child,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: child)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSiguiente,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
