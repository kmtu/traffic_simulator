part of traffic_simulator;

class Controller {
  World model;
  Camera view;
  GameLoopHtml gameLoop;
  FPS fps;

  Controller(this.model, this.view) {
    gameLoop = new GameLoopHtml(document.body);
    gameLoop.processAllKeyboardEvents = false;
    gameLoop.pointerLock.lockOnClick = false;

    model.gameLoop = gameLoop;
    model.dtUpdate = gameLoop.dt;
    view.model = model;

    gameLoop.state = new State(this);

    // prevent default right click context menu from showing up
    gameLoop.element.addEventListener('contextmenu', (e){
      e.preventDefault();
    });

    DivElement fpsDiv = querySelector("#fps");
    fps = new FPS(fpsDiv);
  }

  void start() {
    gameLoop.start();
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

class State extends SimpleHtmlState {
  World model;
  Camera camera;
  GameLoopHtml gameLoop;
  Controller controller;
  State nextState;

  double wheelZoomSensitivity = 0.0005;
  double keyZoomSensitivity = 1.2;

  State(this.controller) {
    model = controller.model;
    camera = controller.view;
    gameLoop = controller.gameLoop;
  }

  void onMouseDown(MouseEvent event) {
    print(event.which);
  }

  void onMouseUp(MouseEvent event) {
    print(event.which);
  }

  void onMouseMove(MouseEvent event) {
    print("(${gameLoop.mouse.clampX}, ${gameLoop.mouse.clampY})");
  }

  void onMouseWheel(WheelEvent event) {
    event.preventDefault();
    var factor = exp(-(event.deltaY * wheelZoomSensitivity).abs());
    if (event.deltaY > 0) {
      camera.zoomIn(factor);
    } else {
      camera.zoomOut(factor);
    }
  }

  void onRender(GameLoop gameLoop) {
    camera.draw();
    controller.fps.sampleFPS();
    if (controller.fps.lastShowPassedDuration.inMilliseconds > 500) {
      controller.fps.showFPS();
    }
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
        camera.beginZoomIn();
        break;
      case Keyboard.X:
        event.preventDefault();
        camera.beginZoomOut();
        break;
      case Keyboard.TAB:
        event.preventDefault();
        if (model.pause) {
          model.pause = false;
        } else {
          model.pause = true;
        }
        super.onKeyDown(event);
        break;
      default:
    }
  }

  void onKeyUp(KeyboardEvent event) {
    switch (event.keyCode) {
      case Keyboard.W:
        event.preventDefault();
        camera.stopMoveUp();
        break;
      case Keyboard.S:
        event.preventDefault();
        camera.stopMoveDown();
        break;
      case Keyboard.A:
        event.preventDefault();
        camera.stopMoveLeft();
        break;
      case Keyboard.D:
        event.preventDefault();
        camera.stopMoveRight();
        break;
      case Keyboard.Z:
        event.preventDefault();
        camera.stopZoomIn();
        break;
      case Keyboard.X:
        event.preventDefault();
        camera.stopZoomOut();
        break;
      default:
    }
  }

  void onResize(GameLoopHtml gameLoop) {
    controller.view.canvas.width = window.innerWidth;
    controller.view.canvas.height = window.innerHeight;
    camera.onResize();
  }

  void onUpdate(GameLoop gameLoop) {
    if (!model.pause) {
      model.update();
    }
    camera.update();
  }
}