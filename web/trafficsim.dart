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

  Vector2 worldSize = new Vector2(120.0, 90.0); // in meters
  world = new TrafficSimulator(worldSize, gameLoop);
  camera = new Camera(film, world, worldPixelPerMeter: 5.0);

  List<Joint> joint = [new SourceJoint("A"), new Joint("B"), new Joint("C")];
  List<Road> road
      = [new Road([new Vector2(20.0, 70.0), new Vector2(100.0, 70.0)],
            numForwardLane: 2, numBackwardLane: 2),
         new Road([new Vector2(105.0, 65.0), new Vector2(65.0, 20.0)],
            numForwardLane: 2, numBackwardLane: 2),
         new Road([new Vector2(60.0, 20.0), new Vector2(15.0, 55.0)],
            numForwardLane: 2, numBackwardLane: 2)
        ];
  road[0].attachJoint(joint[0], Road.BEGIN_SIDE);
  road[0].attachJoint(joint[1], Road.END_SIDE);
  road[1].attachJoint(joint[1], Road.BEGIN_SIDE);
  road[1].attachJoint(joint[2], Road.END_SIDE);
  road[2].attachJoint(joint[2], Road.BEGIN_SIDE);
  road[2].attachJoint(joint[0], Road.END_SIDE);

  world.addRoad(road);
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
        world.pause = false;
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
        world.pause = true;
    }
  }
}
