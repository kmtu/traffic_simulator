library traffic_simulator;

import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

part 'src/driver.dart';
part 'src/road.dart';
part 'src/vehicle.dart';
part 'src/joint.dart';
part 'src/lane.dart';
part 'src/utility.dart';
part 'src/camera.dart';
part 'src/data_structure.dart';

abstract class World {
  Vector2 dimension;
  void draw(Camera camera);
  GameLoopHtml gameLoop;
}

class TrafficSimulator implements World {
  final Set<Road> road = new Set<Road>();
  final Set<Vehicle> vehicle = new Set<Vehicle>();
  final Queue<Vehicle> garage = new Queue<Vehicle>();
  final Set<Joint> joint = new Set<Joint>();
  Vector2 dimension; // meter
  GameLoopHtml gameLoop;
  double dt = 0.0;
  Random random;
  bool pause = false;

  TrafficSimulator(this.dimension, this.gameLoop, [this.random]) {
    if (random == null) {
      random = new Random(new DateTime.now().millisecondsSinceEpoch);
    }
  }

  void addRoad(Iterable<Road> road) {
    for (Road rd in road) {
      rd.world = this;
      this.road.add(rd);
      for (RoadEnd re in rd.roadEnd) {
        if (re.joint != null) {
          re.joint.world = this;
          this.joint.add(re.joint);
        }
      }
    }
  }

  void update() {
    road.forEach((r) => r.update());
    joint.forEach((j) => j.update());
  }

  void draw(Camera camera) {
    if (pause == false) {
      dt = gameLoop.dt * gameLoop.renderInterpolationFactor;
    }

    for (Road rd in road) {
      rd.draw(camera);
    }

    for (Joint joint in this.joint) {
      joint.draw(camera);
    }
  }

  Vehicle requestVehicle() {
    if (garage.isEmpty) {
      return new Vehicle(this);
    }
    else {
      return garage.removeLast();
    }
  }
}