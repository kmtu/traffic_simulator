part of traffic_simulator;

class Controller {
  World world;
  Visualizer visualizer;
  GameLoopHtml gameLoop;
  FPS fps;

  Controller(this.world, this.visualizer) {
    gameLoop = new GameLoopHtml(document.body);
    gameLoop.processAllKeyboardEvents = false;
    gameLoop.pointerLock.lockOnClick = false;

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

  void pause() {
    world.pause = true;
  }

  void unPause() {
    world.pause = false;
  }

  bool get isPaused => world.pause;

  void updateModel() {
    world.update(gameLoop.dt);
  }

  void updateVisualizer() {
    visualizer.update(gameLoop.dt);
  }

  void resize() {
    visualizer.resize();
  }

  void draw() {
    visualizer.draw(gameLoop.dt * gameLoop.renderInterpolationFactor);
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
  Controller controller;
  Camera camera;
  GameLoopHtml gameLoopHtml;

  double wheelZoomSensitivity = 0.0005;

  State(this.controller) {
    camera = controller.visualizer.camera;
    gameLoopHtml = controller.gameLoop;
  }

  void onRender(GameLoop gameLoop) {
    controller.draw();
    controller.fps.sampleFPS();
    if (controller.fps.lastShowPassedDuration.inMilliseconds > 500) {
      controller.fps.showFPS();
    }
  }

  void onResize(GameLoop gameLoop) {
    controller.resize();
  }

  void onUpdate(GameLoop gameLoop) {
    if (!controller.isPaused) {
      controller.updateModel();
    }

    if (gameLoopHtml.mouse.isDown(Mouse.LEFT)) {
      camera.pos.x -= gameLoopHtml.mouse.dx / camera.pixelPerMeter *
        camera.resolutionScaleRatio;
      camera.pos.y -= gameLoopHtml.mouse.dy / camera.pixelPerMeter *
        camera.resolutionScaleRatio;
    }
    var factor = exp(gameLoopHtml.mouse.wheelDy * wheelZoomSensitivity);
    camera.zoomBy(factor);

    if (gameLoopHtml.keyboard.pressed(Keyboard.W)) {
      camera.moveUp();
    }
    if (gameLoopHtml.keyboard.released(Keyboard.W)) {
      camera.stopMoveUp();
    }
    if (gameLoopHtml.keyboard.pressed(Keyboard.A)) {
      camera.moveLeft();
    }
    if (gameLoopHtml.keyboard.released(Keyboard.A)) {
      camera.stopMoveLeft();
    }
    if (gameLoopHtml.keyboard.pressed(Keyboard.S)) {
      camera.moveDown();
    }
    if (gameLoopHtml.keyboard.released(Keyboard.S)) {
      camera.stopMoveDown();
    }
    if (gameLoopHtml.keyboard.pressed(Keyboard.D)) {
      camera.moveRight();
    }
    if (gameLoopHtml.keyboard.released(Keyboard.D)) {
      camera.stopMoveRight();
    }

    if (gameLoopHtml.keyboard.pressed(Keyboard.C)) {
      camera.toCenter();
    }

    if (gameLoopHtml.keyboard.pressed(Keyboard.Z)) {
      camera.beginZoomIn();
    }
    if (gameLoopHtml.keyboard.released(Keyboard.Z)) {
      camera.stopZoomIn();
    }
    if (gameLoopHtml.keyboard.pressed(Keyboard.X)) {
      camera.beginZoomOut();
    }
    if (gameLoopHtml.keyboard.released(Keyboard.X)) {
      camera.stopZoomOut();
    }

    if (gameLoopHtml.keyboard.pressed(Keyboard.P)) {
      if (controller.isPaused) {
        controller.unPause();
      } else {
        controller.pause();
      }
    }

    controller.updateVisualizer();
  }
}
