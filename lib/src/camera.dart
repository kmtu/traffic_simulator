part of traffic_simulator;

class Camera {
  Vector2 pos = new Vector2.zero(); // top-left corner
  Vector2 vel = new Vector2.zero();
  double lineWidth = 1.0;
  double acc = 100.0;
  double maxSpeed = 200.0; // meter per click
  double height; // meters
  double ratio; // = width / height
  World world;
  double worldPixelPerMeter;
  CanvasElement film, worldCanvas;
//  double minZoomFactor; // minZoomFactor <= zoomFactor <= 1 (fill the maximum world.canvas)
  double zoomFactor = 1.0;
  double get width => height * ratio;
  
  Camera(this.film, this.world, {this.worldPixelPerMeter: 10.0})  {
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
    drawWorldBoundary();
    world.draw(this);
    film.context2D.clearRect(0, 0, film.width, film.height);
    film.context2D.drawImageScaledFromSource(worldCanvas, 
      pos.x*worldPixelPerMeter, pos.y*worldPixelPerMeter, width * worldPixelPerMeter, height * worldPixelPerMeter,
      0, 0, film.width, film.height);
  }
  
  void drawWorldBoundary() {
    worldCanvas.context2D.clearRect(0, 0, worldCanvas.width, worldCanvas.height);
    worldCanvas.context2D.save();
    worldCanvas.context2D.beginPath();
    worldCanvas.context2D.strokeStyle = "red";
    worldCanvas.context2D.lineWidth = lineWidth*5;
    worldCanvas.context2D.strokeRect(0, 0, world.dimension.x, world.dimension.y);
    worldCanvas.context2D.restore();
  }
  
  CanvasElement makeCanvas() {
    CanvasElement canvas = new CanvasElement()
           .. width = (world.dimension.x * worldPixelPerMeter).toInt()
           .. height = (world.dimension.y * worldPixelPerMeter).toInt();
    canvas.context2D.scale(worldPixelPerMeter, worldPixelPerMeter);
    return canvas;
  }
  
  void zoom(double factor) {
    zoomFactor *= factor;
    maxSpeed *= factor;
    acc *= factor;
    double dy = height*(1-factor) / 2.0;
    height *= factor;
    pos.y += dy;
    pos.x += dy * ratio;
  }
  
  void zoomIn(double factor) => zoom(1.0 / factor);
  void zoomOut(double factor) => zoom(factor);
  
  void moveRight() {
    if (vel.x >= maxSpeed) {
      vel.x = maxSpeed;
    }
    else {
      vel.x += acc;
    }
  }
  
  void moveLeft() {
    if (vel.x < -maxSpeed) {
      vel.x = -maxSpeed;
    }
    else {
      vel.x -= acc;
    }
  }
  
  void moveUp() {
    if (vel.y < -maxSpeed) {
      vel.y = -maxSpeed;
    }
    else {
      vel.y -= acc;
    }
  }
  
  void moveDown() {
    if (vel.y > maxSpeed) {
      vel.y = maxSpeed;
    }
    else {
      vel.y += acc;
    }
  }
  
  void stopMove() {
    vel.setZero();
  }
  
  void update(double dt) {
    pos += vel*dt;
  }
}
