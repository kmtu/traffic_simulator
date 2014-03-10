part of traffic_simulator;

class WorldView extends View<World> {
  WorldView(CanvasElement canvas, Controller controller) :
      super(canvas, controller);

  @override
  void render() {
    if (controller.pause == false) {
      controller.dtRender = controller.dtUpdate * controller.gameLoop.renderInterpolationFactor;
    }

    for (Road rd in controller.road) {
      rd.render();
    }

    for (Joint joint in controller.joint) {
      joint.render();
    }
  }

  @override
  void update() {
    // TODO: implement update
  }
}