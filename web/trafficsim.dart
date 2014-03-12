import 'dart:html';
import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';
import 'package:traffic_simulator/traffic_simulator.dart';

GameLoopHtml gameLoop;
World world;
Camera camera;

DivElement fpsDiv = querySelector("#fps");

FPS fps = new FPS(fpsDiv);
PauseState pauseState = new PauseState();
RunningState runningState = new RunningState();

void main() {
  CanvasElement canvas = querySelector(".game-element");
  canvas.width = 960;
  canvas.height = 720;
  gameLoop = new GameLoopHtml(canvas);

  world = new World(gameLoop);

  Vector2 center = new Vector2(60.0, 45.0);
  camera = new Camera(canvas, world, pixelPerMeter: 10.0, center: center);
  List<Joint> joint = [new SourceJoint("0"), new Joint("1"),
                       new Joint("2"), new Joint("3")];
  List<Road> road
      = [new Road([new Vector2(20.0, 70.0), new Vector2(55.0, 70.0)],
            numForwardLane: 1, numBackwardLane: 0),
         new Road([new Vector2(60.0, 70.0), new Vector2(105.0, 70.0)],
            numForwardLane: 1, numBackwardLane: 0),
         new Road([new Vector2(105.0, 65.0), new Vector2(65.0, 20.0)],
            numForwardLane: 1, numBackwardLane: 0),
         new Road([new Vector2(60.0, 20.0), new Vector2(20.0, 65.0)],
            numForwardLane: 1, numBackwardLane: 0),
         new Road([new Vector2(62.5, 25.0), new Vector2(57.5, 65.0)],
         numForwardLane: 1, numBackwardLane: 0)
        ];
  road[0].attachJoint(joint[0], Road.BEGIN_SIDE);
  road[0].attachJoint(joint[1], Road.END_SIDE);
  road[1].attachJoint(joint[1], Road.BEGIN_SIDE);
  road[1].attachJoint(joint[2], Road.END_SIDE);
  road[2].attachJoint(joint[2], Road.BEGIN_SIDE);
  road[2].attachJoint(joint[3], Road.END_SIDE);
  road[3].attachJoint(joint[3], Road.BEGIN_SIDE);
  road[3].attachJoint(joint[0], Road.END_SIDE);
  road[4].attachJoint(joint[3], Road.BEGIN_SIDE);
  road[4].attachJoint(joint[1], Road.END_SIDE);

  world.addRoad(road);
  gameLoop.state = runningState;
  gameLoop.start();
}

// Create a simple state implementing only the handlers you care about
class PauseState extends SimpleHtmlState {
  void onRender(GameLoop gameLoop) {
    camera.draw();
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
      case Keyboard.C:
        camera.toCenter();
        break;
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
    camera.draw();
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
      case Keyboard.C:
        camera.toCenter();
        break;
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
