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

abstract class World {
  Vector2 dimension;
  void draw(Camera camera);
}

class TrafficSimulator implements World {
  List<Vehicle> vehicle;
  List<Road> road = new List<Road>();
  Set<Joint> joint = new Set<Joint>();
  Vector2 dimension; // meter
  GameLoopHtml gameLoop;

  TrafficSimulator(this.dimension, this.gameLoop);
  
  void addRoad(Road road) {
    this.road.add(road);
    road.joint.forEach((e) => joint.add(e));
  }
  
  void addJoint(Joint joint) {
    this.joint.add(joint);
  }
  
  void update(gameLoop) {
  }
  
  void draw(Camera camera) {
    for (Road rd in road) {
      rd.draw(camera);
    }
    
    for (Joint joint in joint) {
      joint.draw(camera);
    }
  }
}