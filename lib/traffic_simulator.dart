library traffic_simulator;

import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:vector_math/vector_math.dart';

part 'src/driver.dart';
part 'src/road.dart';
part 'src/vehicle.dart';
part 'src/joint.dart';
part 'src/lane.dart';
part 'src/utility.dart';
part 'src/camera.dart';

abstract class World {
  Vector2 dimension;
  void draw(Camera camera);
}

class TrafficSimulator implements World {
  List<Vehicle> vehicle;
  List<Road> road = new List<Road>();
  Vector2 dimension; // meter

  TrafficSimulator(this.dimension);
  
  void update(double dt) {
  }
  
  void draw(Camera camera) {
    if (road.length > 0) {
      for (var rd in road) {
        rd.draw(camera);
      }
    }
  }
}