import 'package:flutter/material.dart';
import 'package:rah/pages/homepage.dart';
import 'package:rah/pages/reconhecimentopage.dart';
import 'package:rah/pages/treinamentopage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UFF - RAH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002147)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const HomePage(),
        '/treinamento': (context) => const TreinamentoPage(),
        '/reconhecimento': (context) => const ReconhecimentoPage(),
      },
    );
  }
}
