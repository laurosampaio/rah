import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';

class RecognitionPage extends StatefulWidget {
  static const routeName = '/recognition';

  const RecognitionPage({super.key});

  @override
  State<RecognitionPage> createState() => _RecognitionPageState();
}

class _RecognitionPageState extends State<RecognitionPage> {
  String _predictedAction = '';
  bool _isModelLoaded = false;
  bool _isListening = false;
  bool _isStartButtonDisabled = false;
  Interpreter? _interpreter;
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];

  final List<String> classes = [
    'AndandoLeve',
    'AndandoModerado',
    'AndandoVigoroso',
    'DeitadoLeve',
    'DeitadoModerado',
    'DeitadoVigoroso',
    'SentadoLeve',
    'SentadoModerado',
    'SentadoVigoroso'
  ];

  Uint8List _convertToBuffer(List<double> input) {
    var byteData = ByteData(12);
    for (int i = 0; i < input.length; i++) {
      byteData.setFloat32(i * 4, input[i], Endian.little);
    }
    return byteData.buffer.asUint8List();
  }

  int _argmax(List<double> list) {
    var maxIndex = 0;
    var maxValue = list[0];
    for (var i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        _isModelLoaded = true;
      });
    });
    listenToAccelerometer();
  }

  // Load TensorFlow Lite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/rah_model.tflite');

      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  // Predict action
  Future<void> predictAction(List<double> dataPoint) async {
    if (!_isModelLoaded || _interpreter == null) return;

    try {
      var input = dataPoint.map((e) => e.toDouble()).toList();
      var inputBuffer = _convertToBuffer(input);

      var outputBuffer = Uint8List(4 * classes.length).buffer;
      _interpreter!.run(inputBuffer, outputBuffer);

      var output = outputBuffer.asFloat32List();
      var predictedClassIndex = _argmax(output);

      setState(() {
        _predictedAction = classes[predictedClassIndex];
      });
    } catch (e) {
      print('Failed to run inference: $e');
    }
  }

  // Listen to accelerometer
  void listenToAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
      });
      if (_isListening) {
        List<double> accelerometerData = _accelerometerValues;
        predictAction(accelerometerData);
      }
    });
  }

  void startListeningToAccelerometer() {
    _isListening = true;
    setState(() {
      _isStartButtonDisabled = true;
    });
  }

  void stopListeningToAccelerometer() {
    _isListening = false;
    setState(() {
      _isStartButtonDisabled = false;
    });
  }

  void testModelWithExampleInput() {
    List<double> exampleDataPoint = [0.1, 0.2, 0.3]; // Example input
    predictAction(exampleDataPoint);
  }

  @override
  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TensorFlow Lite Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Accelerometer Values:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'X: ${_accelerometerValues[0].toStringAsFixed(2)}, Y: ${_accelerometerValues[1].toStringAsFixed(2)}, Z: ${_accelerometerValues[2].toStringAsFixed(2)}',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isStartButtonDisabled
                    ? null
                    : () {
                        startListeningToAccelerometer();
                      },
                child: const Text('Start Recognition'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  stopListeningToAccelerometer();
                  setState(() {
                    _predictedAction = '';
                  });
                },
                child: const Text('Stop Recognition'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: testModelWithExampleInput,
                child: const Text('Test Model with Example Input'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Predicted Action:',
              ),
              const SizedBox(height: 10),
              Text(
                _predictedAction.isEmpty ? 'N/A' : _predictedAction,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
