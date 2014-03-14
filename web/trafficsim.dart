import 'dart:html';
import 'package:vector_math/vector_math.dart';
import 'package:traffic_simulator/traffic_simulator.dart';

void main() {
  // Creates a view
  CanvasElement canvas = querySelector("#game-element");
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  Camera camera = new Camera(canvas, pixelPerMeter: 2.0, maxWidthPixel: 0,
      maxHeightPixel: 0);

  Vector2 origin = new Vector2.zero();
  var roadGrid = createRoadGrid(p0: origin, row: 5, col: 5, gap: 50.0);

  // Set the starting position for the camera
  camera.center = origin;

  // Creates a world
  World world = new World();
  roadGrid.forEach((rl) => world.addRoad(rl));

  // Combines the world and view
  Controller controller = new Controller(world, camera);
  controller.start();
}

List<List<Road>> createRoadGrid({Vector2 p0, double gap: 50.0, int row: 5, int
    col: 5}) {
  if (p0 == null) {
    p0 = new Vector2.zero();
  }
  int numGridRow = row;
  int numGridCol = col;
  int indexPoint(int r, int c) {
    return c * numGridRow + r;
  }
  int indexRoad(int r, int c) {
    return c * (numGridRow - 1) + r;
  }

  List<Vector2> p = new List<Vector2>(numGridRow * numGridCol);
  for (var c = 0; c < numGridCol; c++) {
    for (var r = 0; r < numGridRow; r++) {
      p[indexPoint(r, c)] = new Vector2(p0.x + c * gap, p0.y + r * gap);
    }
  }

  //  int numRoad = (numGridRow - 1) + (numGridCol - 1) + 2 * (numGridRow - 1) *
  //      (numGridCol - 1);
  List<List<Road>> roadGrid = new List<List<Road>>((numGridRow - 1) *
      (numGridCol - 1));
  for (var c = 0; c < numGridCol - 1; c++) {
    for (var r = 0; r < numGridRow - 1; r++) {
      var roadList = new List<Road>();
      var pp = p[indexPoint(r, c)].clone();
      Road road;
      if (c == 0) {
        road = new Road(pp, new Vector2(pp.x, pp.y + gap), numForwardLane: 2,
            numBackwardLane: 2);
        roadList.add(road);
      }
      if (r == 0) {
        road = new Road(pp, new Vector2(pp.x + gap, pp.y), numForwardLane: 2,
            numBackwardLane: 2);
        roadList.add(road);
      }
      road = new Road(new Vector2(pp.x + gap, pp.y), new Vector2(pp.x + gap,
          pp.y + gap), numForwardLane: 2, numBackwardLane: 2);
      roadList.add(road);
      road = new Road(new Vector2(pp.x, pp.y + gap), new Vector2(pp.x + gap,
          pp.y + gap), numForwardLane: 2, numBackwardLane: 2);
      roadList.add(road);
      roadGrid[indexRoad(r, c)] = roadList;
    }
  }

  List<Joint> joint = new List<Joint>(p.length);
  for (var i = 0; i < joint.length; i++) {
    if (i == 0) {
      joint[i] = new SourceJoint(label: "$i", maxDispatch: 100);
    } else {
      joint[i] = new Joint(label: "$i");
    }
  }

  for (var c = 0; c < numGridCol - 1; c++) {
    for (var r = 0; r < numGridRow - 1; r++) {
      roadGrid[indexRoad(r, c)].forEach((r) {
        r.roadEnd.asMap().forEach((side, re) {
          r.attachJoint(joint[p.indexOf(p.singleWhere((p) => (re.pos.x == p.x)
              && (re.pos.y == p.y)))], side);
        });
      });
    }
  }

  return roadGrid;
}
