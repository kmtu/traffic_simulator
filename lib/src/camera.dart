part of traffic_simulator;

class Camera {
  Vector2 pos = new Vector2.zero(); // top-left corner
  Vector2 vel = new Vector2.zero();
  Vector2 center = new Vector2.zero();
  double acc = 60.0;
  double maxSpeed = 180.0; // meter per click
  double height; // meters
  double ratio; // = width / height
  World model;
  double pixelPerMeter;
  CanvasElement canvas, buffer;
  double minZoomFactor = 0.2;
  // minZoomFactor <= zoomFactor <= 1 (fill the maximum world.canvas)
  double zoomFactor = 1.0;
  double dt;
  Matrix3 transformMatrix;
  int maxHeightPixel;
  int maxWidthPixel;

  Camera(this.canvas, {this.pixelPerMeter:
      10.0, this.center, this.maxHeightPixel: 0, this.maxWidthPixel: 0}) {
    buffer = new CanvasElement();
    onResize();
  }

  double get width => height * ratio; // meters
  Vector2 get center2pos => new Vector2(center.x - width / 2, center.y - height / 2);

  void onResize() {
    ratio = canvas.width / canvas.height;
    if (maxHeightPixel > 0) {
      if (maxWidthPixel > 0) {
        // Choose the limiting one
        if (ratio < 1) {
          // canvas.width < canvas.height, limit height
          if (canvas.height > maxHeightPixel) {
            buffer.height = maxHeightPixel;
          } else {
            buffer.height = canvas.height;
          }
          buffer.width = (buffer.height * ratio).toInt();
        } else {
          // canvas.width > canvas.height, limit width
          if (canvas.width > maxWidthPixel) {
            buffer.width = maxWidthPixel;
          } else {
            buffer.width = canvas.width;
          }
          buffer.height = (buffer.width ~/ ratio);
        }
      } else {
        // Only maxHeightPixel is given, limit height
        if (canvas.height > maxHeightPixel) {
          buffer.height = maxHeightPixel;
        } else {
          buffer.height = canvas.height;
        }
        buffer.width = (buffer.height * ratio).toInt();
      }
    } else {
      if (maxWidthPixel > 0) {
        // Only maxWidthPixel is given, limit width
        if (canvas.width > maxWidthPixel) {
          buffer.width = maxWidthPixel;
        } else {
          buffer.width = canvas.width;
        }
        buffer.height = (buffer.width ~/ ratio);
      } else {
        // No limit, use the original resolution of the device
        buffer
            ..width = canvas.width
            ..height = canvas.height;
      }
    }
    if (height != null) {
      height = buffer.height.toDouble() / pixelPerMeter;
      pos = center2pos;
    } else {
      height = buffer.height.toDouble() / pixelPerMeter;
    }
  }

  void draw() {
    dt = model.gameLoop.dt * model.gameLoop.renderInterpolationFactor;
    transformMatrix = preTranslate(makeScaleMatrix3(pixelPerMeter), -(pos.x +
        vel.x * dt), -(pos.y + vel.y * dt));
    var bufferContext = buffer.context2D;
    bufferContext.clearRect(0, 0, buffer.width, buffer.height);
    bufferContext.save();
    // align the top left corner of the canvas to camera.pos
    transformContext(bufferContext, transformMatrix);
    model.view.draw(this);
    bufferContext.restore();
    canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);
    //    canvas.context2D.drawImage(buffer, 0 , 0);
    canvas.context2D.drawImageScaled(buffer, 0, 0, canvas.width, canvas.height);
  }

  /*  void drawWorldBoundary() {
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();

    context.beginPath();
    context.strokeStyle = "red";
    context.lineWidth = 5;
    context.strokeRect(0, 0, world.dimension.x, world.dimension.y);

    context.restore();
  }*/

  void zoom(double factor) {
    // prevent camera from zooming out of the world canvas
    double zoomFactorTest = zoomFactor * factor;
    //    if (zoomFactorTest >= minZoomFactor) {
    zoomFactor = zoomFactorTest;
    maxSpeed *= factor;
    acc *= factor;
    double dy = height * (1 - factor) / 2.0;
    height *= factor;
    pos.y += dy;
    pos.x += dy * ratio;
    pixelPerMeter /= factor;
    //    }
  }

  void zoomIn(double factor) => zoom(1.0 / factor);
  void zoomOut(double factor) => zoom(factor);

  void moveRight() {
    vel.x += acc;
    if (vel.x >= maxSpeed) {
      vel.x = maxSpeed;
    }
  }

  void moveLeft() {
    vel.x -= acc;
    if (vel.x < -maxSpeed) {
      vel.x = -maxSpeed;
    }
  }

  void moveUp() {
    vel.y -= acc;
    if (vel.y < -maxSpeed) {
      vel.y = -maxSpeed;
    }
  }

  void moveDown() {
    vel.y += acc;
    if (vel.y > maxSpeed) {
      vel.y = maxSpeed;
    }
  }

  void stopMove() {
    vel.setZero();
  }

  void update() {
    double dt = model.gameLoop.dt;
    pos += vel * dt;

    /*    double maxWidth_ = world.dimension.x - width;
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
    }*/
  }

  void reset() {
    zoom(1 / zoomFactor);
    vel.setZero();
    pos.setFrom(center2pos);
  }

  void toCenter() {
    var zm = zoomFactor;
    reset();
    zoom(zm);
  }
}

class Color {
  int r, g, b;
  num a = 1;
  static Random _rand = new Random();

  Color(this.r, this.g, this.b, [this.a]);

  Color.red([this.a]) {
    r = 255;
    g = 0;
    b = 0;
  }

  Color.yellow([this.a]) {
    r = 255;
    g = 255;
    b = 0;
  }

  Color.black() {
    r = 0;
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
    r = _rand.nextInt(max - min + 1) + min;
    g = _rand.nextInt(max - min + 1) + min;
    b = _rand.nextInt(max - min + 1) + min;
  }

  Color clone() {
    return new Color(r, g, b, a);
  }

  @override
  bool operator ==(Color other) {
    if (r == other.r && g == other.g && b == other.b && a == other.a) {
      return true;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return (a + 1) * 10000000 + (r + 1) * 1000000 + (g + 1) * 1000 + b;
  }
}
