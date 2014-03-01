part of traffic_simulator;

class Lane {
  List<Vehicle> vehicle;
  final Road road;
  final double width;
  Lane _prevLane;
  Lane _nextLane;

  Lane(this.road, [this.width = 3.5]);
  
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    for (var veh in vehicle) {
      veh.draw(camera);
    }
    context.restore();
  }
}