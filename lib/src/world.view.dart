part of traffic_simulator;

class WorldView implements View {
  World model;
  WorldView(this.model);
  double dt = 0.0;

  void draw(Camera camera) {
    var context = camera.buffer.context2D;

    if (!model.pause) {
      dt = camera.dt;
    }

    for (Road rd in model.road) {
      rd.view.draw(camera);
    }

    for (Joint joint in model.joint) {
      joint.view.draw(camera);
    }
  }

  void update() {}
}
