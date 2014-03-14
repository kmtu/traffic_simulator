import 'dart:html';
import 'package:vector_math/vector_math.dart';
import 'package:traffic_simulator/traffic_simulator.dart';

void main() {
  // Creates a view
  CanvasElement canvas = querySelector("#game-element");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  Camera camera = new Camera(canvas, pixelPerMeter: 10.0);

  List<Joint> joint = new List<Joint>(4);
  joint[0] = new SourceJoint(label: "0", maxDispatch: 100);
  joint[1] = new Joint(label: "1");
  joint[2] = new SourceJoint(label: "2", maxDispatch: 100);
  joint[3] = new SourceJoint(label: "3", maxDispatch: 100);

  List<Vector2> p = new List<Vector2>(10);
  p[0] = new Vector2(0.0, 0.0);
  p[1] = new Vector2(500.0, 0.0);
  p[2] = new Vector2(505.0, 0.0);
  p[3] = new Vector2(1000.0, 0.0);
  p[4] = new Vector2(1000.0, -10.0);
  p[5] = new Vector2(505.0, -500.0);
  p[6] = new Vector2(500.0, -500.0);
  p[7] = new Vector2(0.0, -10.0);
  p[8] = new Vector2(502.5, -490.0);
  p[9] = new Vector2(502.5, -6.0);

  // You can scale all the points at once
  p.forEach((p) => p.setFrom(p / 1.0));

  // Set the starting position for the camera
  camera.center = p[9];

  List<Road> road = new List<Road>(5);
  road[0] = new Road(p[0], p[1], numForwardLane: 2, numBackwardLane: 2)
          ..attachJoint(joint[0], Road.BEGIN_SIDE)
          ..attachJoint(joint[1], Road.END_SIDE);

  road[1] = new Road(p[2], p[3], numForwardLane: 2, numBackwardLane: 2)
          ..attachJoint(joint[1], Road.BEGIN_SIDE)
          ..attachJoint(joint[2], Road.END_SIDE);

  road[2] = new Road(p[4], p[5], numForwardLane: 2, numBackwardLane: 2)
          ..attachJoint(joint[2], Road.BEGIN_SIDE)
          ..attachJoint(joint[3], Road.END_SIDE);

  road[3] = new Road(p[6], p[7], numForwardLane: 2, numBackwardLane: 2)
          ..attachJoint(joint[3], Road.BEGIN_SIDE)
          ..attachJoint(joint[0], Road.END_SIDE);

  road[4] = new Road(p[8], p[9], numForwardLane: 2, numBackwardLane: 2)
          ..attachJoint(joint[3], Road.BEGIN_SIDE)
          ..attachJoint(joint[1], Road.END_SIDE);

  // Creates a world
  World world = new World();
  world.addRoad(road);

  // Combines the world and view
  Controller controller = new Controller(world, camera);
  controller.start();
}