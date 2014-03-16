part of traffic_simulator;

class RoadView implements View {
  Road model;
  Matrix3 transformMatrix;

  RoadView(this.model);

  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<Lane> _upperLane;
  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<Lane> _lowerLane;
  double boundaryLineWidth = 1.0;

  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.buffer.context2D;
    context.save();
    if (model.forwardLane.isEmpty && model.backwardLane.isEmpty) {
      _drawMiddleLine(camera);
    } else {
      _upperLane.forEach((l) => l.view.draw(camera));
      _lowerLane.forEach((l) => l.view.draw(camera));
      _drawBoundary(camera);
    }
    model.roadEnd.forEach((re) => re.view.draw(camera));
    context.restore();
  }

  void _drawBoundary(Camera camera) {
    CanvasRenderingContext2D context = camera.buffer.context2D;
    context.save();

    transformContext(context, transformMatrix);
    // draw as if the center of the road aligns to the x-axis

    context.beginPath();

    // draw top boundary line
    double totalHalfLaneWidth = model.width / 2 + boundaryLineWidth / 2;
    context.moveTo(0, -totalHalfLaneWidth);
    context.lineTo(model.length, -totalHalfLaneWidth);

    // draw bottom boundary line
    context.moveTo(0, totalHalfLaneWidth);
    context.lineTo(model.length, totalHalfLaneWidth);

    context.setStrokeColorRgb(100, 100, 100);
    context.lineWidth = boundaryLineWidth;
    context.stroke();

    context.restore();
  }

  void _drawMiddleLine(Camera camera) {
    //Draw a line if the road contains no lane
    CanvasRenderingContext2D context = camera.buffer.context2D;
    context.save();
    transformContext(context, transformMatrix);
    // draw as if the center of the road aligns to the x-axis

    context.beginPath();
    context.moveTo(0, 0);
    context.lineTo(model.length, 0);
    context.setStrokeColorRgb(255, 0, 0, 0.5);
    context.lineWidth = 1;
    context.stroke();
    context.restore();
  }

  void update() {
    _updateTransformMatrix();
    _updateDrivingSide();
    _updateLaneTransformMatrix();
    model.roadEnd.forEach((re) => re.view.update());
  }

  void _updateTransformMatrix() {
    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation.
    Vector2 d = model.roadEnd[1].pos - model.roadEnd[0].pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = postTranslate(transformMatrix, model.roadEnd[0].pos.x,
        model.roadEnd[0].pos.y);
  }

  void _updateDrivingSide() {
    if (model.drivingSide == Road.RHT) {
      _upperLane = model.backwardLane;
      _lowerLane = model.forwardLane;

    } else {
      _upperLane = model.forwardLane;
      _lowerLane = model.backwardLane;
    }
  }

  void _updateLaneTransformMatrix() {
    // _upperLane
    double cumWidth_ = 0.0;
    double halfTotalLaneWidth = model.width / 2;
    forEachEntryFromLast(_upperLane, (laneEntry) {
      laneEntry.element.view.transformMatrix = preTranslate(transformMatrix,
          0.0, -halfTotalLaneWidth + cumWidth_);
      cumWidth_ += laneEntry.element.width;
    });

    // _lowerLane
    cumWidth_ = 0.0;
    forEachEntryFromLast(_lowerLane, (laneEntry) {
      cumWidth_ += laneEntry.element.width;
      laneEntry.element.view.transformMatrix = preTranslate(transformMatrix,
          0.0, halfTotalLaneWidth - cumWidth_);
    });
  }
}


class RoadEndView implements View {
  RoadEnd model;
  Matrix3 transformMatrix;
  Color color;
  double _width;

  final Color basicColor = new Color.yellow(0.8);
  final Color spawningColor = new Color.red(0.8);
  Color glowColor;
  double blinkPeriod = 0.3;
  double _accumulatedTime = 0.0;
  bool _finished = false;
  bool _spawning = false;

  RoadEndView(this.model) {
    _width = 4.0;
  }

  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.buffer.context2D;
    context.save();
    if (model.joint != null) {
      transformContext(context, transformMatrix);
      // Draw as if this is a begin road end, and the beginning of the read
      // is origin, the center axis of the road is x axis
      if (model.joint is SourceJoint) {
        _paintGlow(context);
      }
      context.beginPath();
      context.setFillColorRgb(color.r, color.g, color.b);
      context.fillRect(0, -model.road.width / 2, -_width, model.road.width);
      //    context.setStrokeColorRgb(0, 0, 0);
      //    context.lineWidth = 1 / camera.pixelPerMeter;
      //    context.strokeRect(0, 0, model.road.length, model.width);
    }
    context.restore();
  }

  void update() {
    transformMatrix = (model.road.view as RoadView).transformMatrix;
    if (transformMatrix != null) {
      if (model.side == Road.END_SIDE) {
        // This is a [Road.END_SIDE] road end, flip x
        transformMatrix = transformMatrix * postTranslate(makeInvertXMatrix3(),
            model.road.length, 0.0);
      }
    }

    if (model.joint != null) {
      color = (model.joint.view as JointView).color;
    }

    if (model.joint is SourceJoint) {
      var sourceJoint = model.joint as SourceJoint;
      glowColor = basicColor;

      _spawning = sourceJoint.spawning;
      if (_spawning && sourceJoint.spawnLane.laneEnd.first == model) {
        glowColor = spawningColor;
        _accumulatedTime = sourceJoint.accumulatedTime;
      }
    }
  }

  void _paintGlow(CanvasRenderingContext2D context) {
    var sourceJoint = model.joint as SourceJoint;
    if (!_finished) {
      if (_spawning) {
        if (_accumulatedTime > blinkPeriod) {
          glowColor = basicColor;
          _spawning = false;
          if (sourceJoint.maxSpawn == 0) {
            _finished = true;
            glowColor.a = 0.0;
          }
        }
        if (!sourceJoint.world.pause) {
          _accumulatedTime = sourceJoint.accumulatedTime +
              sourceJoint.world.view.dt;
        }
      }
    }
    context.beginPath();
    context.setFillColorRgb(glowColor.r, glowColor.g, glowColor.b, glowColor.a);
    context.fillRect(0, -model.road.width / 2, _width, model.road.width);
  }
}
