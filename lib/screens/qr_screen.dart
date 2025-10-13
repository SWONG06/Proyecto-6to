import 'package:flutter/material.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_2, size: 120),
          const SizedBox(height: 16),
          const Text(
            'Aquí irá tu QR o generador de QR',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Aquí puedes poner la lógica para generar o escanear QR
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Generar / Escanear QR'),
          ),
        ],
      ),
    );
  }
}
