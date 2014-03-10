part of traffic_simulator;

class Road implements Controller {
  World world;
  RoadModel model = new RoadModel();
  RoadView view;

  static const int BEGIN_SIDE = 0;
  static const int END_SIDE = 1;
  /// From endPoint[0] to endPoint[1]
  static const int FORWARD = 401;
  /// From endPoint[1] to endPoint[0]
  static const int BACKWARD = 410;
  /// Right-Hand Traffic
  static const int RHT = 10;
  /// Left-Hand Traffic
  static const int LHT = 11;
  static const int INNER_LANE = 20;
  static const int OUTER_LANE = 21;
  /// Both inner lanes and outer lane are fine
  static const int RANDOM_LANE = 22;

  Road(List<Vector2> end, {int numForwardLane: 1, int numBackwardLane: 1,
      int drivingHand}) {
    if (drivingHand == null) drivingHand = RHT;
    model.drivingHand = drivingHand;

    if (end.length != 2) {
      throw new ArgumentError("Road: there must be two and only two ends in a road.");
    }
    model.roadEnd[0] = new RoadEnd(this, Road.BEGIN_SIDE, end[0], model.forwardLane, model.backwardLane);
    model.roadEnd[1] = new RoadEnd(this, Road.END_SIDE, end[1], model.backwardLane, model.forwardLane);
    updateOnEndChange();
    addLane(numForwardLane, numBackwardLane);
  }

  List<RoadEnd> get roadEnd => model.roadEnd;
  double get width => model.width;
  double get length => model.length;
  DoubleLinkedQueue<Lane> get forwardLane => model.forwardLane;
  DoubleLinkedQueue<Lane> get backwardLane => model.backwardLane;
  double get boundaryLineWidth => model.boundaryLineWidth;
  int get drivingHand => model.drivingHand;

  void addView(RoadView view) {
    this.view = view;
    forwardLane.forEach((l) => l.addView(new LaneView(view.canvas, l)));
    backwardLane.forEach((l) => l.addView(new LaneView(view.canvas, l)));
    view.update();
  }
  void render() => view.render();

  void update() {
    model.forwardLane.forEach((l) => l.update());
    model.backwardLane.forEach((l) => l.update());
  }

  /**
   * Called when positions of endPoints are changed
   */
  void updateOnEndChange() {
    model.length = model.roadEnd[0].pos.distanceTo(model.roadEnd[1].pos).toDouble();
    if (view != null) view.update();
  }

  void updateOnLaneChange() {
    model.width = model.boundaryLineWidth;
    model.forwardLane.forEach((l) => model.width += l.width);
    model.backwardLane.forEach((l) => model.width += l.width);
    if (view != null) view.update();
    roadEnd.forEach((e) => e.updateOnLaneChange());
  }

  void _addLane(Lane ln) {
    if (ln.direction == FORWARD) {
      model.forwardLane.add(ln);
    }
    else if (ln.direction == BACKWARD) {
      model.backwardLane.add(ln);
    }
    else {
      throw new ArgumentError("A lane must have a valid direction when added to road.");
    }
    ln.road = this;
    updateOnLaneChange();
  }

  Road addLane(int numForward, int numBackword) {
    for (int i = 0; i < numForward; i++) {
      Lane lane = new Lane(this, FORWARD);
      this._addLane(lane);
      lane.entry = forwardLane.lastEntry();
    }
    for (int i = 0; i < numBackword; i++) {
      Lane lane = new Lane(this, BACKWARD);
      this._addLane(lane);
      lane.entry = backwardLane.lastEntry();
    }
    return this;
  }

  void attachJoint(Joint joint, int side) {
    if (side == Road.BEGIN_SIDE) {
      roadEnd[Road.BEGIN_SIDE].addJoint(joint);
    }
    else if (side == Road.END_SIDE) {
      roadEnd[Road.END_SIDE].addJoint(joint);
    }
    else {
      throw new ArgumentError("Joint can only be attached to either "
                              "the Road.BEGIN_SIDE or Road.END_SIDE of a road.");
    }
  }

  DoubleLinkedQueue<Lane> getOppositeLane(Lane lane) {
    if (lane.direction == Road.FORWARD) return model.backwardLane;
    else return model.forwardLane;
  }

}

