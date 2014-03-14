part of traffic_simulator;

class JointView implements View {
  Joint model;
  Color labelCircleColor;

  JointView(this.model) {
    labelCircleColor = new Color.random(min: 100);
  }

  void draw(Camera camera) {
    _drawLabel(camera);
  }

  void _drawLabel(Camera camera) {
    CanvasRenderingContext2D context = camera.buffer.context2D;
    for (var roadEnd in model.roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, 3, 0, 2*PI);
      context.setFillColorRgb(labelCircleColor.r, labelCircleColor.g,
          labelCircleColor.b, 0.9);
      context.fill();
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.setFillColorRgb(0, 0, 0);

      // Use larger font first then scale down to workaround the
      // minimum font size problem in Chrome
      context.save();
      context.scale(0.25, 0.25);
      context.font = "16px arial";
      context.fillText(model.label, 0, 0);
      context.restore();

      context.restore();
    }
  }

  void update(){}
}

class SourceJointView extends JointView implements View {
  SourceJoint model;

  final Color basicColor = new Color.yellow(0.8);
  final Color spawningColor = new Color.red(0.8);
  Color color;
  double blinkPeriod = 0.3;
  double _accumulatedTime = 0.0;
  bool _finished = false;
  bool _spawning = false;

  SourceJointView(this.model) : super(null) {
    color = basicColor;
  }

  @override
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.buffer.context2D;
    for (var roadEnd in model.roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, 5, 0, 2*PI);
      if (!_finished) {
        if (_spawning) {
          if (_accumulatedTime > blinkPeriod) {
            color = basicColor;
            _accumulatedTime = 0.0;
            _spawning = false;
          }
          else {
            _accumulatedTime += model.world.view.dt;
          }
        }
      }
      context.setFillColorRgb(color.r, color.g, color.b, color.a);
      context.fill();
      context.restore();
    }
    _drawLabel(camera);
  }

  void update() {
    _spawning = true;
    color = spawningColor;
    if (model.maxDispatch == 0) {
      _finished = true;
      color.a = 0.0;
    }
  }

/*  void updateBlink() {
    _opacity += opacityFreq * model.world.dtUpdate;
    if (_opacity > maxOpacity) {
      _opacity = maxOpacity;
      opacityFreq *= -1;
    }
    else if (_opacity < minOpacity) {
      _opacity = minOpacity;
      opacityFreq *= -1;
    }
  }*/
}