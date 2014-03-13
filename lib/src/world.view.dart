part of traffic_simulator;

class WorldView {
  World world;
  WorldView(this.world);
  double dt = 0.0;

  void draw(Camera camera) {
    var context = camera.buffer.context2D;

    if (world.pause == false) {
      dt = camera.dt;
    }

    for (Road rd in world.road) {
      rd.view.draw(camera);
    }

    for (Joint joint in world.joint) {
      joint.draw(camera);
    }
  }
}
