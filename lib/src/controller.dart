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
    gameLoop.element.addEventListener('contextmenu', (e) {
      e.preventDefault();
    });

    new Manual(gameLoop.element);
    fps = new FPS(gameLoop.element);
  }

  void start() {
    gameLoop.start();
  }
}

class UIPanel {
  Element parent;
  Element panel = new DivElement();
  UIPanel(this.parent) {
    panel.style
        ..backgroundColor = "rgba(200, 200, 200, 0.5)"
        ..position = "fixed"
        ..margin = "1em"
        ..padding = "0.1em 1em"
        ..fontSize = "1.2em"
        ..lineHeight = "1.8em";
    panel.onMouseDown.listen((e) {
      e.preventDefault();
    });
    panel.onMouseMove.listen((e) {
      e.preventDefault();
    });
    parent.append(panel);
  }
}

class Manual extends UIPanel {
  Manual(Element parent): super(parent) {
    panel.style
        ..top = "0px"
        ..left = "0px"
        ..borderRadius = "1em";
    panel.innerHtml =
        "<p>C: 回到起點<br />"
        "TAB: 暫停</p>";
    parent.append(panel);
  }
}

class FPS extends UIPanel {
  DateTime prevTime;
  DateTime currentTime;
  Duration lastShowPassedDuration;
  double fps = 0.0;

  FPS(Element parent): super(parent) {
    panel.style
        ..bottom = "0px"
        ..right = "0px"
        ..borderRadius = "0.5em";
  }

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
    panel.text = "FPS: ${fps.toStringAsFixed(2)}";
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

  void onResize(GameLoopHtml gameLoop) {
    controller.view.canvas.width = window.innerWidth;
    controller.view.canvas.height = window.innerHeight;
    camera.onResize();
  }

  void onUpdate(GameLoop gameLoop) {
    if (!model.pause) {
      model.update();
    }

    if (this.gameLoop.mouse.isDown(Mouse.LEFT)) {
      camera.pos.x -= this.gameLoop.mouse.dx / camera.pixelPerMeter *
        camera.resolutionScaleRatio;
      camera.pos.y -= this.gameLoop.mouse.dy / camera.pixelPerMeter *
        camera.resolutionScaleRatio;
    }
    var factor = exp(this.gameLoop.mouse.wheelDy * wheelZoomSensitivity);
    camera.zoomBy(factor);

    if (this.gameLoop.keyboard.pressed(Keyboard.W)) {
      camera.moveUp();
    }
    if (this.gameLoop.keyboard.released(Keyboard.W)) {
      camera.stopMoveUp();
    }
    if (this.gameLoop.keyboard.pressed(Keyboard.A)) {
      camera.moveLeft();
    }
    if (this.gameLoop.keyboard.released(Keyboard.A)) {
      camera.stopMoveLeft();
    }
    if (this.gameLoop.keyboard.pressed(Keyboard.S)) {
      camera.moveDown();
    }
    if (this.gameLoop.keyboard.released(Keyboard.S)) {
      camera.stopMoveDown();
    }
    if (this.gameLoop.keyboard.pressed(Keyboard.D)) {
      camera.moveRight();
    }
    if (this.gameLoop.keyboard.released(Keyboard.D)) {
      camera.stopMoveRight();
    }

    if (this.gameLoop.keyboard.pressed(Keyboard.C)) {
      camera.toCenter();
    }

    if (this.gameLoop.keyboard.pressed(Keyboard.Z)) {
      camera.beginZoomIn();
    }
    if (this.gameLoop.keyboard.released(Keyboard.Z)) {
      camera.stopZoomIn();
    }
    if (this.gameLoop.keyboard.pressed(Keyboard.X)) {
      camera.beginZoomOut();
    }
    if (this.gameLoop.keyboard.released(Keyboard.X)) {
      camera.stopZoomOut();
    }

    if (this.gameLoop.keyboard.pressed(Keyboard.P)) {
      if (model.pause) {
        model.pause = false;
      } else {
        model.pause = true;
      }
    }

    camera.update();
  }
}
