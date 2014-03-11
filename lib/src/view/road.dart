part of traffic_simulator;

class RoadView extends View<Road> {
  final List<RoadEndView> roadEndView = new List<RoadEndView>(2);
  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<LaneView> upperLaneView;
  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<LaneView> lowerLaneView;

  /// Lanes which direction are [Road.FORWARD]
  /// First added will be drawn as inner lanes
  final DoubleLinkedQueue<LaneView> forwardLaneView = new DoubleLinkedQueue<LaneView>();

  /// Lanes which direction are [Road.BACKWARD]
  /// First added will be drawn as inner lanes
  final DoubleLinkedQueue<LaneView> backwardLaneView = new DoubleLinkedQueue<LaneView>();

  RoadView(CanvasElement canvas, Road road) :
      super(canvas, road) {
    this.roadEndView[0] = new RoadEndView(canvas, road.roadEnd[0]);
    this.roadEndView[1] = new RoadEndView(canvas, road.roadEnd[1]);
    road.forwardLane.forEach((l) => this.forwardLaneView.add(new LaneView(canvas, l)));
    road.backwardLane.forEach((l) => this.backwardLaneView.add(new LaneView(canvas, l)));
    update();
  }


  double get _halfTotalLaneWidth =>
      controller.width / 2 - controller.boundaryLineWidth / 2;

  @override
  void update() {
    if (controller.drivingHand == Road.RHT) {
      upperLaneView = backwardLaneView;
      lowerLaneView = forwardLaneView;
    }
    else {
      upperLaneView = forwardLaneView;
      lowerLaneView = backwardLaneView;
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
    forEachEntryFromLast(this.upperLaneView, (laneEntry){
      laneEntry.element.view.transformMatrix = preTranslate(
          transformMatrix, 0.0, -_halfTotalLaneWidth + cumWidth_);
      cumWidth_ += laneEntry.element.width;
    });
  }

  void updateLowerLane() {
    double cumWidth_ = 0.0;
    // update from outer lane
    forEachEntryFromLast(this.lowerLaneView, (laneEntry){
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
      _drawUpperLane(upperLaneView);
      _drawLowerLane(lowerLaneView);
      _drawBoundary();
    }
    roadEndView.forEach((re) => re.render());
    context.restore();
  }

  void _drawUpperLane(DoubleLinkedQueue<LaneView> lane) {
    double cumWidth_ = 0.0;
    // draw from outer lane
    forEachEntryFromLast(lane, (laneEntry) => laneEntry.element.render());
  }

  void _drawLowerLane(DoubleLinkedQueue<LaneView> lane) {
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