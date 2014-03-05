import 'dart:html';
import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';
import 'package:driversim/traffic_simulator.dart';

GameLoopHtml gameLoop;
TrafficSimulator world;
Camera camera;

const int WIDTH = 800;
const int HEIGHT = 600;
DivElement fpsDiv = querySelector("#fps");

FPS fps = new FPS(fpsDiv);
PauseState pauseState = new PauseState();
RunningState runningState = new RunningState();

void main() {
  CanvasElement film = querySelector(".game-element");
  film.width = WIDTH;
  film.height = HEIGHT;
  gameLoop = new GameLoopHtml(film);

  Vector2 worldSize = new Vector2(100.0, 75.0); // in meters
  world = new TrafficSimulator(worldSize, gameLoop);
  camera = new Camera(film, world);

  List<Joint> joint = [new SourceJoint("A"), new SourceJoint("B"), new SourceJoint("C")];
  world.addRoad(new Road([new Vector2(10.0, 60.0), new Vector2(90.0, 60.0)],
      numForwardLane: 2, numBackwardLane: 2));
  world.attachJointToRoad(joint[0], world.road[0], Road.BEGIN_SIDE);
  world.attachJointToRoad(joint[1], world.road[0], Road.END_SIDE);
  
  world.addRoad(new Road([new Vector2(90.0, 60.0), new Vector2(55.0, 10.0)],
      numForwardLane: 1, numBackwardLane: 0));
  world.attachJointToRoad(joint[1], world.road[1], Road.BEGIN_SIDE);
  world.attachJointToRoad(joint[2], world.road[1], Road.END_SIDE);

  world.addRoad(new Road([new Vector2(55.0, 10.0), new Vector2(10.0, 60.0)],
      numForwardLane: 3, numBackwardLane: 2));
  world.attachJointToRoad(joint[2], world.road[2], Road.BEGIN_SIDE);
  world.attachJointToRoad(joint[0], world.road[2], Road.END_SIDE);
  gameLoop.state = runningState;
  gameLoop.start();
}

// Create a simple state implementing only the handlers you care about
class PauseState extends SimpleHtmlState {
  void onRender(GameLoop gameLoop) {
    camera.shoot();
    fps.sampleFPS();
    if (fps.lastShowPassedDuration.inMilliseconds > 500) {
      fps.showFPS();
    }
  }

  void onUpdate(GameLoop gameLoop) {
    camera.update();
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
        gameLoop.state = runningState;
    }
  }
}

class FPS {
  DateTime prevTime;
  DateTime currentTime;
  Duration lastShowPassedDuration;
  double fps = 0.0;
  DivElement div;
  
  FPS(this.div);
  
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
    div.text = "FPS: ${fps.toStringAsFixed(2)}";
    lastShowPassedDuration = new Duration();
  }
}

class RunningState extends SimpleHtmlState {
  void onRender(GameLoop gameLoop) {
    camera.shoot();
    fps.sampleFPS();
    if (fps.lastShowPassedDuration.inMilliseconds > 500) {
      fps.showFPS();
    }
  }
    
  void onUpdate(GameLoop gameLoop) {
    world.update();
    camera.update();
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
        gameLoop.state = pauseState;
    }
  }
}
