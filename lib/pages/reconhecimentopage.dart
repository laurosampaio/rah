import 'package:flutter/material.dart';

class ReconhecimentoPage extends StatelessWidget {
  const ReconhecimentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecimento de Atividade'),
      ),
      body: const Center(
        child: Text(
          'Reconhecimento de Atividade',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
