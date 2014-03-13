part of traffic_simulator;

class RoadView implements View {
  Road model;
  RoadView(this.model) {
    update();
  }

  Matrix3 transformMatrix;

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
    }
    else {
      _upperLane.forEach((l) => l.view.draw(camera));
      _lowerLane.forEach((l) => l.view.draw(camera));
      _drawBoundary(camera);
    }
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
  }

  void _updateTransformMatrix() {
    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation.
    Vector2 d = model.roadEnd[1].pos - model.roadEnd[0].pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = postTranslate(transformMatrix, model.roadEnd[0].pos.x, model.roadEnd[0].pos.y);
  }

  void _updateDrivingSide() {
    if (model.drivingSide == Road.RHT) {
      _upperLane = model.backwardLane;
      _lowerLane = model.forwardLane;

    }
    else {
      _upperLane = model.forwardLane;
      _lowerLane = model.backwardLane;
    }
  }

  void _updateLaneTransformMatrix() {
    // _upperLane
    double cumWidth_ = 0.0;
    double halfTotalLaneWidth = model.width / 2;
    forEachEntryFromLast(_upperLane, (laneEntry){
      laneEntry.element.view.transformMatrix =
          preTranslate(transformMatrix, 0.0, -halfTotalLaneWidth + cumWidth_);
      cumWidth_ += laneEntry.element.width;
    });

    // _lowerLane
    cumWidth_ = 0.0;
    forEachEntryFromLast(_lowerLane, (laneEntry){
      cumWidth_ += laneEntry.element.width;
      laneEntry.element.view.transformMatrix =
          preTranslate(transformMatrix, 0.0, halfTotalLaneWidth - cumWidth_);
    });
  }
}
