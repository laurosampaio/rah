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
  List<String> _actions = [];
  bool _isModelLoaded = false;
  bool _isListening = false;
  bool _isStartButtonDisabled = false;
  Interpreter? _interpreter;
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];

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
  Future<void> predictAction(List<List<double>> input) async {
    if (!_isModelLoaded || _interpreter == null) return;

    try {
      List<Object?> inputList = [input];
      List<Object?> outputList = [List.filled(1, 0.0, growable: true)];

      _interpreter!.run(inputList, outputList);

      setState(() {
        _actions = outputList[0] as List<String>;
      });
    } catch (e) {
      print('Failed to run inference: $e');
    }
  }

  // Listen to accelerometer
  void listenToAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = [event.x ?? 0.0, event.y ?? 0.0, event.z ?? 0.0];
      });
      if (_isListening) {
        List<double> accelerometerData = _accelerometerValues;
        predictAction([accelerometerData]);
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
          title: Text('TensorFlow Lite Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Accelerometer Values:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'X: ${_accelerometerValues[0].toStringAsFixed(2)}, Y: ${_accelerometerValues[1].toStringAsFixed(2)}, Z: ${_accelerometerValues[2].toStringAsFixed(2)}',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isStartButtonDisabled
                    ? null
                    : () {
                        startListeningToAccelerometer();
                      },
                child: Text('Start Recognition'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  stopListeningToAccelerometer();
                  setState(() {
                    _actions = [];
                  });
                },
                child: Text('Stop Recognition'),
              ),
              SizedBox(height: 20),
              Text(
                'Predicted Action:',
              ),
              SizedBox(height: 10),
              Text(
                _actions.isNotEmpty ? _actions[0] : 'N/A',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
