part of traffic_simulator;

class Vehicle {
  Vector2 pos;
  Vector2 vel;
  Vector2 acc;
  Lane lane;
  Driver driver;
  double width;
  double length;

  Vehicle(this.lane, {this.width, this.length, this.driver}) {
    if (driver == null) {
      this.driver = new Driver(vehicle: this);
    }
  }
    
  void draw(Camera camera, Matrix3 transformMatrix) {
    // the lane center is x-axs, lane begins from origin
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    transformContext(context, preTranslate(transformMatrix, pos.x, pos.y));
    // draw as if the reference point of the vehicle is the origin
    
    context.fillStyle = "blue";
    context.fillRect(-length, -width / 2, length, width);
    context.restore();
  }

  void update(GameLoopHtml gameLoop) {
  }
}
