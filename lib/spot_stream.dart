import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SpotStream {
  Stream<List<FlSpot>> get spots => setSpots.stream;

  Stream<String> get average => setAverage.stream;

  Stream<String> get min => setMin.stream;

  Stream<String> get max => setMax.stream;

  StreamController<List<FlSpot>> setSpots = StreamController<List<FlSpot>>();

  StreamController<String> setAverage = StreamController<String>();
  StreamController<String> setMin = StreamController<String>();
  StreamController<String> setMax = StreamController<String>();

  Timer? t;

  startListening() {
    t?.cancel();
    late UserAccelerometerEvent current;
    List<FlSpot> s = [];
    double currentTotal = 0;
    double currentAverage = 0;
    double currentMin = 0.5;
    double currentMax = 0;
    double count = 0;

    setSpots.sink.add([const FlSpot(0, 0)]);
    userAccelerometerEvents.listen((event) {
      current = event;
    });

    t = Timer.periodic(const Duration(seconds: 1), (timer) async {
      double z = current.z > 0.5
          ? 0.5
          : current.z < -0.5
              ? -0.5
              : current.z;
      s = [...s, FlSpot(count, z)];
      currentTotal += z;
      currentAverage = currentTotal / (count + 1);
      currentMin = z < currentMin ? z : currentMin;
      currentMax = z > currentMax ? z : currentMax;
      setAverage.sink.add(currentAverage.toStringAsFixed(3));
      setMin.sink.add(currentMin.toStringAsFixed(3));
      setMax.sink.add(currentMax.toStringAsFixed(3));
      setSpots.sink.add(s);
      count++;
      if (count >= 60) {
        timer.cancel();
      }
    });
  }

  stopListening() {
    t?.cancel();
  }

  dispose() {
    setSpots.close();
    spots.drain();
  }
}
