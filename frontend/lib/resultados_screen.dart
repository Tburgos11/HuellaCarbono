import 'package:flutter/material.dart';

class ResultadosScreen extends StatelessWidget {
  final String resultado;
  const ResultadosScreen({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Resultados de Huella de Carbono'),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tarjeta principal con el resultado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.eco,
                        size: 80,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tu huella de carbono estimada es:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade50, Colors.green.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '$resultado kg CO₂',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildImpactInfo(resultado),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Botón de donación
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/donaciones');
                    },
                    icon: const Icon(Icons.favorite, size: 24),
                    label: const Text(
                      'Compensar mi huella - Hacer donación',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón para volver al inicio
                TextButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Hacer nuevo cálculo'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImpactInfo(String resultado) {
    double co2 = double.tryParse(resultado) ?? 0;
    String impactText = '';
    Color impactColor = Colors.green;
    IconData impactIcon = Icons.eco;

    if (co2 < 100) {
      impactText = '¡Excelente! Tu huella es baja';
      impactColor = Colors.green;
      impactIcon = Icons.eco;
    } else if (co2 < 300) {
      impactText = 'Tu huella es moderada';
      impactColor = Colors.orange;
      impactIcon = Icons.warning_amber;
    } else {
      impactText = 'Considera reducir tu huella';
      impactColor = Colors.red;
      impactIcon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: impactColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: impactColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(impactIcon, color: impactColor, size: 20),
          const SizedBox(width: 8),
          Text(
            impactText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: impactColor,
            ),
          ),
        ],
      ),
    );
  }
}
