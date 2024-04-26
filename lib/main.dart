import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocímetro',
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SpeedometerPage(title: 'Velocímetro'),
    );
  }
}

class SpeedometerPage extends StatefulWidget {
  const SpeedometerPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SpeedometerPage> createState() => _SpeedometerPageState();
}

class _SpeedometerPageState extends State<SpeedometerPage> {
  static const Duration _ignoreDuration = Duration(milliseconds: 60);
  int _speed = 0;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  DateTime? _accelerometerUpdateTime;
  // ignore: unused_field
  int? _accelerometerLastInterval;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    _streamSubscriptions.add(
      userAccelerometerEventStream(
              samplingPeriod: SensorInterval.normalInterval)
          .listen(
        (event) {
          final now = DateTime.now();
          setState(() {
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
                // Calcula a velocidade usando a aceleração linear em m/s²
                double acceleration =
                    event.x.abs() + event.y.abs() + event.z.abs();
                // Considerando 1 m/s² = 3.6 km/h
                _speed = (acceleration * 3.6).toInt();
              }
            }
            _accelerometerUpdateTime = now;
          });
        },
        onError: (e) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text('Sensor não encontrado'),
                content:
                    Text('Seu dispositivo não suporta sensor acelerômnetro'),
              );
            },
          );
        },
        cancelOnError: true,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_speed',
              style: const TextStyle(
                fontSize: 192.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
