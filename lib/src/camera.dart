part of traffic_simulator;

class Camera {
  Vector2 pos = new Vector2.zero(); // top-left corner
  Vector2 vel = new Vector2.zero();
  double acc = 50.0;
  double maxSpeed = 100.0; // meter per click
  double height; // meters
  double ratio; // = width / height
  World world;
  double worldPixelPerMeter;
  CanvasElement film, worldCanvas;
  double minZoomFactor = 0.2; // minZoomFactor <= zoomFactor <= 1 (fill the maximum world.canvas)
  double zoomFactor = 1.0;
  double get width => height * ratio;
  double dt;
  
  Camera(this.film, this.world, {this.worldPixelPerMeter: 10.0})  {
    worldCanvas= makeCanvas();
    ratio = film.width / film.height;
    double worldRatio = world.dimension.x / world.dimension.y;
    if (ratio <= worldRatio) {
      height = world.dimension.y;
    }
    else {
      height = world.dimension.x / ratio;
    }
  }
  
  void shoot() {
    dt = world.gameLoop.dt * world.gameLoop.renderInterpolationFactor;
    worldCanvas.context2D.clearRect(pos.x, pos.y, width, height);
    world.draw(this);
    drawWorldBoundary();
    film.context2D.clearRect(0, 0, film.width, film.height);
    film.context2D.drawImageScaledFromSource(worldCanvas, 
      (pos.x + vel.x * dt) * worldPixelPerMeter,
      (pos.y + vel.y * dt) * worldPixelPerMeter,
      width * worldPixelPerMeter,
      height * worldPixelPerMeter,
      0, 0, film.width, film.height);
  }
  
  void drawWorldBoundary() {
    CanvasRenderingContext2D context = worldCanvas.context2D;
    context.save();
    
    context.beginPath();
    context.strokeStyle = "red";
    context.lineWidth = 5;
    context.strokeRect(0, 0, world.dimension.x, world.dimension.y);
    
    context.restore();
  }
  
  CanvasElement makeCanvas() {
    CanvasElement canvas = new CanvasElement()
           .. width = (world.dimension.x * worldPixelPerMeter).toInt()
           .. height = (world.dimension.y * worldPixelPerMeter).toInt();
    canvas.context2D.scale(worldPixelPerMeter, worldPixelPerMeter);
    return canvas;
  }
  
  void zoom(double factor) {
    // prevent camera from zooming out of the world canvas
    double zoomFactorTest = zoomFactor * factor;
    if (zoomFactorTest <= 1 && zoomFactorTest >= minZoomFactor) {
      zoomFactor = zoomFactorTest;
      maxSpeed *= factor;
      acc *= factor;
      double dy = height*(1-factor) / 2.0;
      height *= factor;
      pos.y += dy;
      pos.x += dy * ratio;
    }
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
  
  void update() {
    double dt = world.gameLoop.dt;
    pos += vel*dt;
    
    double maxWidth_ = world.dimension.x - width;
    double maxHeight = world.dimension.y - height;

    if (pos.x < 0) {
      pos.x = 0.0;
      vel.x = 0.0;
    }
    else if (pos.x > maxWidth_) {
      pos.x = maxWidth_;
      vel.x = 0.0;
    }
    if (pos.y < 0) {
      pos.y = 0.0;
      vel.y = 0.0;
    }
    else if (pos.y > maxHeight) {
      pos.y = maxHeight;
      vel.y = 0.0;
    }
  }
}

class Color {
  int r, g, b;
  num a = 1;
  static Random _rand = new Random();
  
  Color(this.r, this.g, this.b, [this.a]);
  
  Color.red() {
    r = 255;
    g = 0;
    b = 0;    
  }
  
  /**
   * [min] and [max] should be integers 0-255
   * [max] should be greater than [min]
   * 
   * No check is performed for efficiency
   */
  Color.random({int min: 0, int max: 255}) {
    r = _rand.nextInt(max-min+1) + min;
    g = _rand.nextInt(max-min+1) + min;
    b = _rand.nextInt(max-min+1) + min;
  }
    
  Color clone() {
    return new Color(r, g, b, a);
  }
  
  @override
  bool operator ==(Color other) {
    if (r == other.r && g == other.g && b == other.b && a == other.a) {
      return true;
    }
    else {
      return false;
    }
  }
  
  @override
  int get hashCode {
    return (a+1) * 10000000 + (r+1) * 1000000 + (g+1) * 1000 + b;
  }
}
