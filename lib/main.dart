import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sensor_test/spot_stream.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: "Sample Sensor App"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  SpotStream spotStream = SpotStream();
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  double count = 0;
  double currentCount = 0;
  List<FlSpot> accelerometerSpots = [];
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues?.map((double v) {
      return v.toStringAsFixed(3);
    }).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(3))
        .toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final magnetometer =
        _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    //
    // Timer t = Timer.periodic(Duration(seconds: 30), (timer) {
    //   accelerometerSpots = [
    //     ...accelerometerSpots,
    //     FlSpot(count, double.tryParse(accelerometer![1]) ?? 0)
    //   ];
    //   spotStream.setSpots.sink.add(accelerometerSpots);
    //
    //   print(accelerometerSpots);
    //
    //   count++;
    //   if (count == 60) {
    //     timer.cancel();
    //   }
    // });
    //
    // if(count == 60)
    //   {
    //     t.cancel();
    //   }
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        spotStream.startListening();
      }, child: Icon(Icons.refresh_outlined),),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder(
                      stream: spotStream.min,
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Min",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "${snapshot.data ?? '0.0'}",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w600),
                            )
                          ],
                        );
                      }),
                  StreamBuilder(
                      stream: spotStream.average,
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Avg",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "${snapshot.data ?? '0.0'}",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w600),
                            )
                          ],
                        );
                      }),
                  StreamBuilder(
                      stream: spotStream.max,
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Max",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "${snapshot.data ?? '0.0'}",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w600),
                            )
                          ],
                        );
                      }),
                ],
              ),
            ),
            StreamBuilder(
                stream: spotStream.spots,
                builder: (context, snapshot) {
                  // print(snapshot.data);
                  return Container(
                    height: 500,
                    child: LineChart(LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                              color: const Color(0xff4af699),
                              barWidth: 2,
                              isStrokeCapRound: false,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                              spots: snapshot.data as List<FlSpot>,
                              show: true)
                        ],
                        minX: 0,
                        maxX: 59,
                        maxY: 0.5,
                        minY: -0.5,

                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          ),
                        ))),
                  );
                }),
            // Text("UserAccelerometer:  $userAccelerometer"),
            // Text("Gyroscope:  $gyroscope"),
            // Text("Magnetometer:  $magnetometer"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    spotStream.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    spotStream.startListening();
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}
