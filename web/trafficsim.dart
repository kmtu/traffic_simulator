import 'dart:html';
import 'dart:math';
import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';
import 'package:driversim/traffic_simulator.dart';

GameLoopHtml gameLoop;
TrafficSimulator world;
Camera camera;

const int WIDTH = 1200;
const int HEIGHT = 400;
DivElement fpsDiv = querySelector("#fps");

void main() {
  CanvasElement film = querySelector(".game-element");
  film.width = WIDTH;
  film.height = HEIGHT;
  gameLoop = new GameLoopHtml(film);

  Vector2 worldSize = new Vector2(150.0, 50.0); // in meters
  world = new TrafficSimulator(worldSize, gameLoop);
  camera = new Camera(film, world);

/*  List<Joint> joint = [new Joint(new Vector2(20.0, 20.0)), new Joint(new Vector2(130.0, 20.0)),
                       new Joint(new Vector2(130.0, 90.0)), new Joint(new Vector2(20.0, 90.0))];
  List<Road> road = [new Road([joint[0], joint[1]]).addLane(1,1),
                     new Road([joint[1], joint[2]]).addLane(1,2),
                     new Road([joint[2], joint[3]]).addLane(2,2),
                     new Road([joint[3], joint[0]]).addLane(1,3),
                     new Road([joint[0], joint[2]]).addLane(3,1),
                     new Road([joint[1], joint[3]]).addLane(3,3)]; */
  
  List joint = [new SourceJoint(new Vector2(20.0, 20.0)), new Joint(new Vector2(130.0, 35.0))];
  List<Road> road = [new Road([joint[0], joint[1]], numForwardLane: 2, numBackwardLane: 2)];
  road.forEach((r) => world.addRoad(r));

  gameLoop.state = runningState;
  gameLoop.start();
}

GameLoopHtmlState initialState = new InitialState();
RunningState runningState = new RunningState();

// Create a simple state implementing only the handlers you care about
class InitialState extends SimpleHtmlState {
  void onRender(GameLoop gameLoop) {
  }

  void onKeyDown(KeyboardEvent event) {
    event.preventDefault();
    gameLoop.state = runningState;
  }
}

class FPS {
  DateTime prevTime;
  DateTime currentTime;
  Duration lastShowPassedDuration;
  double fps = 0.0;
  void sampleFPS() {
    if (prevTime == null) {
      prevTime = new DateTime.now();
      lastShowPassedDuration = new Duration();
    }
    else {
      currentTime = new DateTime.now();
      Duration dt = currentTime.difference(prevTime);
      lastShowPassedDuration += dt;
      fps = 0.05*fps + 0.95*(1000.0 / dt.inMilliseconds);
      prevTime = currentTime;
    }
  }
  
  void showFPS() {
    fpsDiv.text = "FPS: ${fps.toStringAsFixed(2)}";
    lastShowPassedDuration = new Duration();
  }
}

class RunningState extends SimpleHtmlState {
  FPS fps = new FPS();
  void onRender(GameLoop gameLoop) {
    camera.shoot();
    fps.sampleFPS();
    if (fps.lastShowPassedDuration.inMilliseconds > 500) {
      fps.showFPS();
    }
  }
    
  void onUpdate(GameLoop gameLoop) {
    world.update(gameLoop.dt);
    camera.update(gameLoop.dt);
  }

  void onKeyDown(KeyboardEvent event) {
    event.preventDefault();
    switch (event.keyCode) {
      case Keyboard.W:
        camera.moveUp();
        break;
      case Keyboard.S:
        camera.moveDown();
        break;
      case Keyboard.A:
        camera.moveLeft();
        break;
      case Keyboard.D:
        camera.moveRight();
        break;
      case Keyboard.Z:
        camera.zoomIn(1.5);
        break;
      case Keyboard.X:
        camera.zoomOut(1.5);
        break;
      case Keyboard.SPACE:
        camera.stopMove();
        break;
      default:
        gameLoop.state = initialState;
    }
  }
}
