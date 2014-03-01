part of traffic_simulator;

class Vehicle {
  Vector2 pos;
  Vector2 vel;
  Vector2 acc;
  Lane lane;
  Driver driver;

  Vehicle(Lane lane, [this.driver]) {
    if (driver == null) {
      this.driver = new Driver(vehicle: this);
    }
  }
    
  @override
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    context.restore();
  }
}
