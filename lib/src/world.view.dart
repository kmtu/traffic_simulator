part of traffic_simulator;

class WorldView {
  World world;
  WorldView(this.world);
  double dtRender = 0.0;

  void draw(Camera camera) {
    var dt = camera.dt;
    var context = camera.buffer.context2D;

    if (world.pause == false) {
      dtRender = world.gameLoop.dt * world.gameLoop.renderInterpolationFactor;
    }

    for (Road rd in world.road) {
      rd.draw(camera);
    }

    for (Joint joint in world.joint) {
      joint.draw(camera);
    }
  }
}
