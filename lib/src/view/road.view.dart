part of traffic_simulator;

class RoadView extends View<Road> {
  RoadView(CanvasElement canvas, Controller controller) :
      super(canvas, controller);

  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<Lane> _upperLane;
  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<Lane> _lowerLane;


  double get _halfTotalLaneWidth =>
      controller.width / 2 - controller.boundaryLineWidth / 2;

  @override
  void update() {
    if (controller.drivingHand == Road.RHT) {
      _upperLane = controller.backwardLane;
      _lowerLane = controller.forwardLane;
    }
    else {
      _upperLane = controller.forwardLane;
      _lowerLane = controller.backwardLane;
    }

    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation.
    Vector2 d = controller.roadEnd[1].pos - controller.roadEnd[0].pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = postTranslate(transformMatrix, controller.roadEnd[0].pos.x, controller.roadEnd[0].pos.y);

    updateUpperLane();
    updateLowerLane();
  }

  void updateUpperLane() {
    double cumWidth_ = 0.0;
    // update from outer lane
    forEachEntryFromLast(this._upperLane, (laneEntry){
      laneEntry.element.view.transformMatrix = preTranslate(
          transformMatrix, 0.0, -_halfTotalLaneWidth + cumWidth_);
      cumWidth_ += laneEntry.element.width;
    });
  }

  void updateLowerLane() {
    double cumWidth_ = 0.0;
    // update from outer lane
    forEachEntryFromLast(this._lowerLane, (laneEntry){
      cumWidth_ += laneEntry.element.width;
      laneEntry.element.view.transformMatrix = preTranslate(
          transformMatrix, 0.0, _halfTotalLaneWidth - cumWidth_);
    });
  }

  @override
  void render() {
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();
    if (controller.forwardLane.isEmpty && controller.backwardLane.isEmpty) {
      _drawMiddleLine();
    }
    else {
      _drawUpperLane(_upperLane);
      _drawLowerLane(_lowerLane);
      _drawBoundary();
    }
    context.restore();
  }

  void _drawUpperLane(DoubleLinkedQueue<Lane> lane) {
    double cumWidth_ = 0.0;
    // draw from outer lane
    forEachEntryFromLast(lane, (laneEntry) => laneEntry.element.render());
  }

  void _drawLowerLane(DoubleLinkedQueue<Lane> lane) {
    double cumWidth_ = 0.0;
    // draw from outer lane
    forEachEntryFromLast(lane, (laneEntry) => laneEntry.element.render());
  }

  void _drawBoundary() {
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();

    transformContext(context, transformMatrix);
    // draw as if the center of the road aligns to the x-axis

    context.beginPath();

    // draw top boundary line
    context.moveTo(0, -_halfTotalLaneWidth);
    context.lineTo(controller.length, -_halfTotalLaneWidth);

    // draw bottom boundary line
    context.moveTo(0, _halfTotalLaneWidth);
    context.lineTo(controller.length, _halfTotalLaneWidth);

    context.setStrokeColorRgb(100, 100, 100);
    context.lineWidth = controller.boundaryLineWidth;
    context.stroke();

    context.restore();
  }

  void _drawMiddleLine() {
    //Draw a line if the road contains no lane
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();
    transformContext(context, transformMatrix);
    // draw as if the center of the road aligns to the x-axis

    context.beginPath();
    context.moveTo(0, 0);
    context.lineTo(controller.length, 0);
    context.setStrokeColorRgb(255, 0, 0, 0.5);
    context.lineWidth = 1;
    context.stroke();
    context.restore();
  }
}