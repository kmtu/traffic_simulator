part of traffic_simulator;

class Camera {
  Vector2 pos = new Vector2.zero(); // top-left corner
  Vector2 vel = new Vector2.zero();
  double friction = 0.1;
  double acc = 500.0; // 10/dt = 66
  double height; // meters
  double _minHeight;
  double ratio; // = width / height
  World world;
  double worldPixelPerMeter;
  CanvasElement film, worldCanvas;
  double maxSpeed = 500.0; // meter per click
//  double minZoomFactor; // minZoomFactor <= zoomFactor <= 1 (fill the maximum world.canvas)
  double currentZoomFactor = 1.0;
  double get width => height * ratio;
  
  Camera(this.film, this.world, {this.worldPixelPerMeter: 5.0})  {
    _minHeight = film.height / worldPixelPerMeter;
    worldCanvas= makeCanvas();
    ratio = film.width / film.height;
    if (world.dimension.y <= world.dimension.x) {
      height = world.dimension.y;
    }
    else {
      height = world.dimension.x / ratio;
    }
  }
  
  void shoot() {
    worldCanvas.context2D.clearRect(0, 0, worldCanvas.width, worldCanvas.height);
    worldCanvas.context2D.save();
    worldCanvas.context2D.beginPath();
    worldCanvas.context2D.strokeStyle = "red";
    worldCanvas.context2D.lineWidth = 10;
    worldCanvas.context2D.strokeRect(0, 0, width/currentZoomFactor-1, height/currentZoomFactor-1);
    worldCanvas.context2D.restore();
    world.draw(this);
    film.context2D.clearRect(0, 0, film.width, film.height);
    film.context2D.drawImageScaledFromSource(worldCanvas, 
      pos.x*worldPixelPerMeter, pos.y*worldPixelPerMeter, width * worldPixelPerMeter, height * worldPixelPerMeter,
      0, 0, film.width, film.height);
  }
  
  CanvasElement makeCanvas() {
    CanvasElement canvas = new CanvasElement()
           .. width = (world.dimension.x * worldPixelPerMeter).toInt()
           .. height = (world.dimension.y * worldPixelPerMeter).toInt();
    canvas.context2D.scale(worldPixelPerMeter, worldPixelPerMeter);
    return canvas;
  }
  
  void zoom(double factor) {
    currentZoomFactor *= factor;
    double oldHeight = height;
    height *= factor;
    double dy = (oldHeight - height) / 2.0;
    pos.y += dy;
    pos.x += dy * ratio;
  }
  
  void zoomIn(double factor) => zoom(1.0 / factor);
  void zoomOut(double factor) => zoom(factor);
  
  void moveRight() {
    if (vel.x < maxSpeed) {
      vel.x += acc;
    }
  }
  
  void moveLeft() {
    if (vel.x > -maxSpeed) {
      vel.x -= acc;
    }
  }
  
  void moveUp() {
    if (vel.y > -maxSpeed) {
      vel.y -= acc;
    }
  }
  
  void moveDown() {
    if (vel.y < maxSpeed) {
      vel.y += acc;
    }
  }
  
  void stopMove() {
    vel.setZero();
  }
  
  void update(double dt) {
    pos += vel*dt;
 //   vel.x.abs() > 1 ? vel.x -= friction * vel.x: vel.x = 0.0;
 //   vel.y.abs() > 1 ? vel.y -= friction * vel.y: vel.y = 0.0;
  }
}
