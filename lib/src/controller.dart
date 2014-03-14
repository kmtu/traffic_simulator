part of traffic_simulator;

class Controller {
  World model;
  Camera view;
  GameLoopHtml gameLoop;
  PauseState pauseState;
  RunningState runningState;
  FPS fps;

  Controller(this.model, this.view) {
    gameLoop = new GameLoopHtml(document.body);
    gameLoop.processAllKeyboardEvents = false;
    gameLoop.pointerLock.lockOnClick = false;

    model.gameLoop = gameLoop;
    model.dtUpdate = gameLoop.dt;
    view.model = model;

    pauseState = new PauseState(this);
    runningState = new RunningState(this);

    gameLoop.state = runningState;

    DivElement fpsDiv = querySelector("#fps");
    fps = new FPS(fpsDiv);
  }

  void start() {
    gameLoop.start();
  }
}

class State extends SimpleHtmlState {
  World model;
  Camera camera;
  GameLoopHtml gameLoop;
  Controller controller;
  State(this.controller) {
    model = controller.model;
    camera = controller.view;
    gameLoop = controller.gameLoop;
  }

  void onRender(GameLoop gameLoop) {
    camera.draw();
    controller.fps.sampleFPS();
    if (controller.fps.lastShowPassedDuration.inMilliseconds > 500) {
      controller.fps.showFPS();
    }
  }
}

// Create a simple state implementing only the handlers you care about
class PauseState extends State {
  PauseState(Controller controller) : super(controller);

  void onUpdate(GameLoop gameLoop) {
    camera.update();
  }

  void onResize(GameLoopHtml gameLoop) {
    controller.view.canvas.width = window.innerWidth;
    controller.view.canvas.height = window.innerHeight;
    camera.onResize();
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
        gameLoop.state = controller.runningState;
        model.pause = false;
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

class RunningState extends State {
  RunningState(Controller controller) : super(controller);

  void onResize(GameLoopHtml gameLoop) {
    controller.view.canvas.width = window.innerWidth;
    controller.view.canvas.height = window.innerHeight;
    camera.onResize();
  }

  void onUpdate(GameLoop gameLoop) {
    model.update();
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
        gameLoop.state = controller.pauseState;
        model.pause = true;
        break;
      default:
    }
  }
}
