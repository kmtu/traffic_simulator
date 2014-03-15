part of traffic_simulator;

class Camera {
  Vector2 pos = new Vector2.zero(); // top-left corner
  Vector2 vel = new Vector2.zero();
  Vector2 acc = new Vector2.zero();
  Vector2 _center;
  int _accPressed = 0; // pixel per sec^2

  /// Initial moving speed when move key is pressed
  int _initialSpeed = 500; // pixel per sec
  int _maxSpeed = 5000; // pixel per sec
  double height; // meters
  double ratio; // = width / height
  World model;
  double _pixelPerMeter;
  CanvasElement canvas, buffer;
  //  double minZoomFactor = 0.2;
  // minZoomFactor <= zoomFactor <= 1 (fill the maximum world.canvas)
  double zoomFactor = 1.0;
  double dt;
  Matrix3 transformMatrix;
  int maxHeightPixel;
  int maxWidthPixel;

  double get pixelPerMeter => _pixelPerMeter;

  Camera(this.canvas, {this.height, Vector2 center, this.maxHeightPixel:
      0, this.maxWidthPixel: 0}) {
    if (center == null) {
      this._center = new Vector2.zero();
    } else {
      this.center = center;
    }

    if (height == null) {
      height = canvas.height.toDouble();
      _pixelPerMeter = canvas.height.toDouble() / height;
    }

    buffer = new CanvasElement();
    onResize();
  }

  double get _accPressedInMeter => _accPressed.toDouble() / _pixelPerMeter;
  double get _initialSpeedInMeter => _initialSpeed.toDouble() / _pixelPerMeter;
  double get _maxSpeedInMeter => _maxSpeed.toDouble() / _pixelPerMeter;

  double get width => height * ratio; // meters
  Vector2 get _center2pos => new Vector2(_center.x - width / 2, _center.y -
      height / 2);
  void set center(Vector2 c) {
    this._center = c;
    pos = _center2pos;
  }

  void onResize() {
    var oldHeight, oldWidth;
    if (ratio != null) {
      oldHeight = height;
      oldWidth = width;
    }
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
    if (oldHeight != null) {
      pos.setValues(pos.x + (oldWidth - width) / 2, pos.y + (oldHeight - height) / 2);
    } else {
      pos = _center2pos;
    }
    _pixelPerMeter = buffer.height.toDouble() / height;
  }

  void draw() {
    dt = model.gameLoop.dt * model.gameLoop.renderInterpolationFactor;
    transformMatrix = preTranslate(makeScaleMatrix3(_pixelPerMeter), -(pos.x +
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
    _pixelPerMeter /= factor;
    zoomFactor = zoomFactorTest;
    double dy = height * (1 - factor) / 2.0;
    height *= factor;
    pos.y += dy;
    pos.x += dy * ratio;
    vel *= factor;
    //    }
  }

  void zoomIn(double factor) => zoom(1.0 / factor);
  void zoomOut(double factor) => zoom(factor);

  void moveRight() {
    if (vel.x <= 0) {
      vel.x = _initialSpeedInMeter;
      acc.x = _accPressedInMeter;
    }
    if (vel.x > _maxSpeedInMeter) {
      vel.x = _maxSpeedInMeter;
    }
  }

  void moveLeft() {
    if (vel.x >= 0) {
      vel.x = -_initialSpeedInMeter;
      acc.x = -_accPressedInMeter;
    }
    if (vel.x < -_maxSpeedInMeter) {
      vel.x = -_maxSpeedInMeter;
    }
  }

  void moveUp() {
    if (vel.y >= 0) {
      vel.y = -_initialSpeedInMeter;
      acc.y = -_accPressedInMeter;
    }
    if (vel.y < -_maxSpeedInMeter) {
      vel.y = -_maxSpeedInMeter;
    }
  }

  void moveDown() {
    if (vel.y <= 0) {
      vel.y = _initialSpeedInMeter;
      acc.y = _accPressedInMeter;
    }
    if (vel.y > _maxSpeedInMeter) {
      vel.y = _maxSpeedInMeter;
    }
  }

  void stopMoveX() {
    vel.x = 0.0;
    acc.x = 0.0;
  }

  void stopMoveY() {
    vel.y = 0.0;
    acc.y = 0.0;
  }

  void update() {
    double dt = model.gameLoop.dt;
    pos += vel * dt;
    vel += acc * dt;

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
    pos.setFrom(_center2pos);
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
