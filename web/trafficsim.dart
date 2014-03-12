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
  canvas.width = 800;
  canvas.height = 600;
  gameLoop = new GameLoopHtml(canvas);
  gameLoop.processAllKeyboardEvents = false;
  gameLoop.pointerLock.lockOnClick = false;
  world = new World(gameLoop);

  camera = new Camera(canvas, world, pixelPerMeter: 10.0);

  List<Joint> joint = new List<Joint>(4);
  joint[0] = new SourceJoint(label: "0", maxDispatch: 1000);
  joint[1] = new Joint(label: "1");
  joint[2] = new SourceJoint(label: "2", maxDispatch: 1000);
  joint[3] = new SourceJoint(label: "3", maxDispatch: 1000);

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
  p[9] = new Vector2(502.5, -5.0);

  camera.center = p[1];

  List<Road> road = new List<Road>(5);
  road[0] = new Road(p[0], p[1], numForwardLane: 3, numBackwardLane: 0)
          ..attachJoint(joint[0], Road.BEGIN_SIDE)
          ..attachJoint(joint[1], Road.END_SIDE);

  road[1] = new Road(p[2], p[3], numForwardLane: 3, numBackwardLane: 0)
          ..attachJoint(joint[1], Road.BEGIN_SIDE)
          ..attachJoint(joint[2], Road.END_SIDE);

  road[2] = new Road(p[4], p[5], numForwardLane: 3, numBackwardLane: 0)
          ..attachJoint(joint[2], Road.BEGIN_SIDE)
          ..attachJoint(joint[3], Road.END_SIDE);

  road[3] = new Road(p[6], p[7], numForwardLane: 3, numBackwardLane: 0)
          ..attachJoint(joint[3], Road.BEGIN_SIDE)
          ..attachJoint(joint[0], Road.END_SIDE);

  road[4] = new Road(p[8], p[9], numForwardLane: 3, numBackwardLane: 0)
          ..attachJoint(joint[3], Road.BEGIN_SIDE)
          ..attachJoint(joint[1], Road.END_SIDE);

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
    //    event.preventDefault();
    switch (event.keyCode) {
      case Keyboard.C:
        event.preventDefault();
        camera.toCenter();
        break;
      case Keyboard.W:
        event.preventDefault();
        camera.moveUp();
        break;
      case Keyboard.S:
        event.preventDefault();
        camera.moveDown();
        break;
      case Keyboard.A:
        event.preventDefault();
        camera.moveLeft();
        break;
      case Keyboard.D:
        event.preventDefault();
        camera.moveRight();
        break;
      case Keyboard.Z:
        event.preventDefault();
        camera.zoomIn(1.5);
        break;
      case Keyboard.X:
        event.preventDefault();
        camera.zoomOut(1.5);
        break;
      case Keyboard.SPACE:
        event.preventDefault();
        camera.stopMove();
        break;
      case Keyboard.TAB:
        event.preventDefault();
        gameLoop.state = runningState;
        world.pause = false;
        break;
      default:
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
    } else {
      currentTime = new DateTime.now();
      Duration dt = currentTime.difference(prevTime);
      lastShowPassedDuration += dt;
      fps = 0.05 * fps + 0.95 * (1000.0 / dt.inMilliseconds);
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
    //    event.preventDefault();
    switch (event.keyCode) {
      case Keyboard.C:
        event.preventDefault();
        camera.toCenter();
        break;
      case Keyboard.W:
        event.preventDefault();
        camera.moveUp();
        break;
      case Keyboard.S:
        event.preventDefault();
        camera.moveDown();
        break;
      case Keyboard.A:
        event.preventDefault();
        camera.moveLeft();
        break;
      case Keyboard.D:
        event.preventDefault();
        camera.moveRight();
        break;
      case Keyboard.Z:
        event.preventDefault();
        camera.zoomIn(1.5);
        break;
      case Keyboard.X:
        event.preventDefault();
        camera.zoomOut(1.5);
        break;
      case Keyboard.SPACE:
        event.preventDefault();
        camera.stopMove();
        break;
      case Keyboard.TAB:
        event.preventDefault();
        gameLoop.state = pauseState;
        world.pause = true;
        break;
      default:
    }
  }
}
