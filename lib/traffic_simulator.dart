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
part 'src/data-structure.dart';

abstract class World {
  Vector2 dimension;
  void draw(Camera camera);
  GameLoopHtml gameLoop;
}

class TrafficSimulator implements World {
  List<Road> road = new List<Road>();
  Queue<Vehicle> garage = new Queue<Vehicle>();
  Set<Joint> orphanJoint = new Set<Joint>();
  Set<Joint> attachedJoint = new Set<Joint>();
  Vector2 dimension; // meter
  GameLoopHtml gameLoop;
  Random random;

  TrafficSimulator(this.dimension, this.gameLoop, [this.random]) {
    if (random == null) {
      random = new Random(new DateTime.now().millisecondsSinceEpoch);
    }
  }
  
  void addRoad(Road road) {
    road.world = this;
    this.road.add(road);
  }
  
  void attachJointToRoad(Joint joint, Road road, int side) {
    joint.world = this;
    road.addJoint(joint, side);
    attachedJoint.add(joint);
  }
  
  void update() {
    road.forEach((r) => r.update());
    attachedJoint.forEach((j) => j.update());
  }
  
  void draw(Camera camera) {
    for (Road rd in road) {
      rd.draw(camera);
    }
    
    for (Joint joint in orphanJoint) {
      joint.drawOrphan(camera);
    }
  }
  
  Vehicle requestVehicle() {
    if (garage.isEmpty) {
      return new Vehicle();
    }
    else {
      return garage.removeLast();
    }
  }
}