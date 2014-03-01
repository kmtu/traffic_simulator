import 'dart:html';
import 'dart:math';
import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';
import 'package:driversim/traffic_simulator.dart';

GameLoopHtml gameLoop;
TrafficSimulator world;
Camera camera;

const int WIDTH = 500;
const int HEIGHT = 500;

void main() {
  CanvasElement film = querySelector(".game-element");
  film.width = WIDTH;
  film.height = HEIGHT;
  
  Vector2 worldSize = new Vector2(500.0, 500.0); // in meters
  
  world = new TrafficSimulator(worldSize);
  camera = new Camera(film, world);

  List<Joint> joint = [new Joint(new Vector2(50.0, 50.0)), new Joint(new Vector2(450.0, 50.0)),
                       new Joint(new Vector2(50.0, 450.0)), new Joint(new Vector2(450.0, 450.0))
                      ];
  world.road.add(new Road([joint[0], joint[1]]));
  world.road.add(new Road([joint[1], joint[2]]));
  world.road.add(new Road([joint[2], joint[3]]));
  world.road.add(new Road([joint[3], joint[0]]));
  world.road.add(new Road([joint[0], joint[2]]));
  world.road.add(new Road([joint[1], joint[3]]));

  gameLoop = new GameLoopHtml(film);
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

    print("Key event");
    print("Switching to $runningState");
    print("Rendering with ${runningState.onRender}}");
    gameLoop.state = runningState;
  }
}

class RunningState extends SimpleHtmlState {
  void onRender(GameLoop gameLoop) {
    camera.shoot();
  }
  
  void onUpdate(GameLoop gameLoop) {
    world.update(gameLoop.dt);
    camera.update(gameLoop.dt);
  }

  void onKeyDown(KeyboardEvent event) {
    event.preventDefault();
    print("KeyDown!");

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
