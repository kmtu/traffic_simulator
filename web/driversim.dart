import 'dart:html';
import 'dart:math';
import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

GameLoopHtml gameLoop;
CanvasRenderingContext2D canvas;

const int WIDTH = 640;
const int HEIGHT = 480;

void main() {
  CanvasElement element = querySelector(".game-element");
  gameLoop = new GameLoopHtml(element);
  canvas = element.context2D;

  gameLoop.state = runningState;
  gameLoop.start();
}

GameLoopHtmlState initialState = new InitialState();
RunningState runningState = new RunningState();
Car car = new Car(new Vector2(WIDTH/2, HEIGHT/2), new Vector2.zero());
Random random = new Random(new DateTime.now().millisecond);
num r = 0;

// Create a simple state implementing only the handlers you care about
class InitialState extends SimpleHtmlState {
  void onRender(GameLoop gameLoop) {
    print("Render initialState");
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
    print("Render runningState");
    draw(canvas);
  }
  
  void onUpdate(GameLoop gameLoop) {
    car.pos += new Vector2((random.nextDouble()*2 - 1)*10, (random.nextDouble()*2 - 1)*10);
    car.pos.x %= WIDTH;
    car.pos.y %= HEIGHT;
    //car.pos += car.vel*gameLoop.updateTimeStep;
    r = (gameLoop.frame)%30;
  }

  void onKeyDown(KeyboardEvent event) {
    event.preventDefault();

    print("Key event");
    print("Switching to $initialState");
    print("Rendering with ${initialState.onRender}");
    gameLoop.state = initialState;
  }
}

void draw(CanvasRenderingContext2D context) {
  context.clearRect(0, 0, WIDTH, HEIGHT);
  context.beginPath();
  context.arc(car.pos.x, car.pos.y, r, 0, PI * 2, true); 
  context.stroke();
}

class Car {
  Vector2 vel;
  Vector2 pos;
  Car(this.pos, this.vel);
}