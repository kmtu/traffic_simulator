part of traffic_simulator;

class Vehicle {
  double pos = 0.0;
  double vel = 10.0;
  double acc = 0.0;
  Lane lane;
  Driver driver;
  double width;
  double length;

  Vehicle({this.width: 1.6, this.length: 3.5, this.driver}) {
    if (driver == null) {
      this.driver = new Driver(vehicle: this);
    }
  }
    
  void draw(Camera camera, Matrix3 transformMatrix) {
    // the lane center is x-aixs, lane begins from origin to the positive x
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    transformContext(context, preTranslate(transformMatrix, pos, 0.0));
    // draw as if the reference point of the vehicle is the origin
    
    context.fillStyle = "blue";
    context.fillRect(-length, -width / 2, length, width);
    context.restore();
  }

  void update() {
    double dt = lane.road.world.gameLoop.dt;
    pos += vel*dt;
  }
}
