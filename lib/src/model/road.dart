part of traffic_simulator;

class Road implements Model{
  Controller<Road> controller;

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

  World world;
  double boundaryLineWidth = 1.0;

  /// Length of this road in meters
  double length;

  double width;
  /// Right-Hand Traffic or Left-Hand Traffic.
  /// Can be [Road.RHT] or [Road.LHT].
  int drivingHand;

  /// Lanes which direction are [Road.FORWARD]
  /// First added will be drawn as inner lanes
  final DoubleLinkedQueue<LaneController> forwardLane = new DoubleLinkedQueue<LaneController>();

  /// Lanes which direction are [Road.BACKWARD]
  /// First added will be drawn as inner lanes
  final DoubleLinkedQueue<LaneController> backwardLane = new DoubleLinkedQueue<LaneController>();

  /// Position of the two [roadEnd] of this road
  final List<RoadEndController> roadEnd = new List<RoadEndController>(2);

  Road(List<Vector2> end, {int numForwardLane: 1, int numBackwardLane: 1,
      int drivingHand}) {
    if (drivingHand == null) drivingHand = Road.RHT;
    this.drivingHand = drivingHand;

    if (end.length != 2) {
      throw new ArgumentError("Road: there must be two and only two ends in a road.");
    }
    this.roadEnd[0] = new RoadEndController(this, Road.BEGIN_SIDE, end[0], this.forwardLane, this.backwardLane);
    this.roadEnd[1] = new RoadEndController(this, Road.END_SIDE, end[1], this.backwardLane, this.forwardLane);
    updateOnEndChange();
    addLane(numForwardLane, numBackwardLane);
  }
}