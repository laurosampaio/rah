import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';
import 'dart:typed_data';

class RecognitionPage extends StatefulWidget {
  static const routeName = '/recognition';

  const RecognitionPage({super.key});

  @override
  State<RecognitionPage> createState() => _RecognitionPageState();
}

class _RecognitionPageState extends State<RecognitionPage> {
  late Interpreter _interpreter;
  List<double>? _accelerometerValues;
  String _prediction = 'Indefinido';
  String _erro = '';
  bool _isRecognizing = false;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/rah_model.tflite');
    } catch (e) {
      _erro = 'Erro ao carregar modelo model: $e';
      print(_erro);
    }
  }

  void _startRecognition() {
    setState(() {
      _isRecognizing = true;
    });
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        _runModel();
      });
    });
  }

  void _stopRecognition() {
    setState(() {
      _isRecognizing = false;
      _accelerometerValues = null;
      _prediction = 'Indefinido';
      _erro = '';
    });
    _accelerometerSubscription.cancel();
  }

  void _runModel() {
    if (_accelerometerValues == null || !_isRecognizing) return;

    // Prepare input data as Float32List
    var input = _accelerometerValues!.map((e) => e.toDouble()).toList();
    var inputBuffer = Float32List.fromList(input).buffer.asUint8List();

    // Create an output buffer
    var outputBuffer = Float32List(10).buffer.asUint8List();

    try {
      // Run inference
      _interpreter.run(inputBuffer, outputBuffer);

      // Process output
      var output = outputBuffer.buffer.asFloat32List();
      var predictedIndex = output
          .indexOf(output.reduce((curr, next) => curr > next ? curr : next));
      setState(() {
        _prediction = 'Ação => $predictedIndex';
      });
    } catch (e) {
      _erro = 'Erro executando modelo: $e';
      print(_erro);
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    if (_isRecognizing) {
      _accelerometerSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((v) => v.toStringAsFixed(1)).toList() ??
            ['0.0', '0.0', '0.0'];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reconhecimento de atividade'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Acelerômetro: $accelerometer'),
              const SizedBox(height: 20),
              Text('Predição: $_prediction'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRecognizing ? null : _startRecognition,
                child: const Text('Iniciar Reconhecimento'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isRecognizing ? _stopRecognition : null,
                child: const Text('Parar Reconhecimento'),
              ),
              const SizedBox(height: 30),
              Text(
                _erro,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
