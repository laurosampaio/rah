import 'package:flutter/material.dart';

class TreinamentoPage extends StatefulWidget {
  const TreinamentoPage({super.key});

  @override
  State<TreinamentoPage> createState() => _TreinamentoPageState();
}

class _TreinamentoPageState extends State<TreinamentoPage> {
  final _txtIdentificador = TextEditingController();

  @override
  void initState() {
    super.initState();
    _txtIdentificador.addListener(() {
      final String text = _txtIdentificador.text.toLowerCase();
      _txtIdentificador.value = _txtIdentificador.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    _txtIdentificador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamento de Atividades'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              TextFormField(
                controller: _txtIdentificador,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Identificação',
                ),
              ),
              const SizedBox(height: 30),
              const Text('Posição'),
              const PositionChoice(),
              const SizedBox(height: 30),
              const Text('Modo'),
              const ModeChoice(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Iniciar'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

enum PositionEnum { lying, sitting, wallking }

class PositionChoice extends StatefulWidget {
  const PositionChoice({super.key});

  @override
  State<PositionChoice> createState() => _PositionChoiceState();
}

class _PositionChoiceState extends State<PositionChoice> {
  PositionEnum positionView = PositionEnum.lying;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PositionEnum>(
      segments: const <ButtonSegment<PositionEnum>>[
        ButtonSegment<PositionEnum>(
            value: PositionEnum.lying,
            label: Text('Deitado'),
            icon: Icon(Icons.bed_outlined)),
        ButtonSegment<PositionEnum>(
            value: PositionEnum.sitting,
            label: Text('Sentado'),
            icon: Icon(Icons.chair_outlined)),
        ButtonSegment<PositionEnum>(
            value: PositionEnum.wallking,
            label: Text('Andando'),
            icon: Icon(Icons.directions_walk)),
      ],
      selected: <PositionEnum>{positionView},
      onSelectionChanged: (Set<PositionEnum> newSelection) {
        setState(() {
          positionView = newSelection.first;
        });
      },
    );
  }
}

enum ModeEnum { light, moderate, vigorous }

class ModeChoice extends StatefulWidget {
  const ModeChoice({super.key});

  @override
  State<ModeChoice> createState() => _ModeChoiceState();
}

class _ModeChoiceState extends State<ModeChoice> {
  ModeEnum modeView = ModeEnum.light;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ModeEnum>(
      segments: const <ButtonSegment<ModeEnum>>[
        ButtonSegment<ModeEnum>(
            value: ModeEnum.light,
            label: Text('Leve'),
            icon: Icon(Icons.arrow_forward)),
        ButtonSegment<ModeEnum>(
            value: ModeEnum.moderate,
            label: Text('Moderado'),
            icon: Icon(Icons.arrow_forward)),
        ButtonSegment<ModeEnum>(
            value: ModeEnum.vigorous,
            label: Text('Vigoroso'),
            icon: Icon(Icons.arrow_forward)),
      ],
      selected: <ModeEnum>{modeView},
      onSelectionChanged: (Set<ModeEnum> newSelection) {
        setState(() {
          modeView = newSelection.first;
        });
      },
    );
  }
}
