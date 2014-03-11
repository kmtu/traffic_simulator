part of traffic_simulator;

class RoadController extends Controller<Road> {
  Road _model;
  List<RoadView> view;

  get model => _model;
  set model (World world) {
    this._model = world;
    view.forEach((v) => v.setWorld(world));
  }

  RoadController(List<Vector2> end, {int numForwardLane: 1, int numBackwardLane: 1,
      int drivingHand, Road model, List<RoadView> view}) : super(model: model, view: view) {
    if (drivingHand == null) drivingHand = RHT;
    _model.drivingHand = drivingHand;

    if (end.length != 2) {
      throw new ArgumentError("Road: there must be two and only two ends in a road.");
    }
    _model.roadEnd[0] = new RoadEndController(this, Road.BEGIN_SIDE, end[0], _model.forwardLane, _model.backwardLane);
    _model.roadEnd[1] = new RoadEndController(this, Road.END_SIDE, end[1], _model.backwardLane, _model.forwardLane);
    updateOnEndChange();
    addLane(numForwardLane, numBackwardLane);
  }

  List<RoadEndController> get roadEnd => _model.roadEnd;
  double get width => _model.width;
  double get length => _model.length;
  DoubleLinkedQueue<LaneController> get forwardLane => _model.forwardLane;
  DoubleLinkedQueue<LaneController> get backwardLane => _model.backwardLane;
  double get boundaryLineWidth => _model.boundaryLineWidth;
  int get drivingHand => _model.drivingHand;

/*  void addView(RoadView view) {
    this.view = view;
    forwardLane.forEach((l) => l.addView(new LaneView(view.canvas, l)));
    backwardLane.forEach((l) => l.addView(new LaneView(view.canvas, l)));
    view.update();
  }*/

//  void render() => view.render();

  void update() {
    _model.forwardLane.forEach((l) => l.update());
    _model.backwardLane.forEach((l) => l.update());
  }

  /**
   * Called when positions of endPoints are changed
   */
  void updateOnEndChange() {
    _model.length = _model.roadEnd[0].pos.distanceTo(_model.roadEnd[1].pos).toDouble();
    if (view != null) view.update();
  }

  void updateOnLaneChange() {
    _model.width = _model.boundaryLineWidth;
    _model.forwardLane.forEach((l) => _model.width += l.width);
    _model.backwardLane.forEach((l) => _model.width += l.width);
    if (view != null) view.update();
    roadEnd.forEach((e) => e.updateOnLaneChange());
  }

  void _addLane(LaneController ln) {
    if (ln.direction == FORWARD) {
      _model.forwardLane.add(ln);
    }
    else if (ln.direction == BACKWARD) {
      _model.backwardLane.add(ln);
    }
    else {
      throw new ArgumentError("A lane must have a valid direction when added to road.");
    }
    ln.road = this;
    updateOnLaneChange();
  }

  Road addLane(int numForward, int numBackword) {
    for (int i = 0; i < numForward; i++) {
      LaneController lane = new LaneController(this, FORWARD);
      this._addLane(lane);
      lane.entry = forwardLane.lastEntry();
    }
    for (int i = 0; i < numBackword; i++) {
      LaneController lane = new LaneController(this, BACKWARD);
      this._addLane(lane);
      lane.entry = backwardLane.lastEntry();
    }
    return this;
  }

  void attachJoint(JointController joint, int side) {
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

  DoubleLinkedQueue<LaneController> getOppositeLane(LaneController lane) {
    if (lane.direction == Road.FORWARD) return _model.backwardLane;
    else return _model.forwardLane;
  }

}

