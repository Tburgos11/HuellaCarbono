import 'package:flutter/material.dart';

class BolitasNavegacion extends StatelessWidget {
  final int cantidad;
  final int actual;
  final Function(int) onTap;

  const BolitasNavegacion({
    super.key,
    required this.cantidad,
    required this.actual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(cantidad, (index) {
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: actual == index ? Colors.green : Colors.grey[300],
              ),
            ),
          );
        }),
      ),
    );
  }
}
