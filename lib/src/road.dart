part of traffic_simulator;

class Road {
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

  RoadView view;

  /// Lanes which direction are [Road.FORWARD]
  /// First added will be drawn as inner lanes
  final BacktraceReversibleDBLQ<Lane> forwardLane = new BacktraceReversibleDBLQ<Lane>();

  /// Lanes which direction are [Road.BACKWARD]
  /// First added will be drawn as inner lanes
  final BacktraceReversibleDBLQ<Lane> backwardLane = new BacktraceReversibleDBLQ<Lane>();

  /// Position of the two [roadEnd] of this road
  final List<RoadEnd> roadEnd = new List<RoadEnd>(2);

  /// Length of this road in meters
  double length;
  /// Right-Hand Traffic or Left-Hand Traffic.
  /// Can be [Road.RHT] or [Road.LHT].
  int _drivingSide;

  double width = 0.0;

  World world;

  Road(Vector2 begin, Vector2 end, {int numForwardLane: 1, int numBackwardLane: 1,
      int drivingSide: Road.RHT, this.view}) {
    roadEnd[0] = new RoadEnd(this, Road.BEGIN_SIDE, begin, forwardLane, backwardLane);
    roadEnd[1] = new RoadEnd(this, Road.END_SIDE, end, backwardLane, forwardLane);
    updateOnEndChange();
    _drivingSide = drivingSide;
    addLane(numForwardLane, numBackwardLane);
    if (view == null) {
      view = new RoadView(this);
    }
    else {
      view.updateDrivingSide();
      view.updateTransformMatrix();
    }
  }

  /**
   *  Set the [drivingSide] of this road
   *  Can be [Road.RHT] or [Road.LHT].
   */
  void set drivingSide(int drivingSide) {
    this._drivingSide = drivingSide;
    if (view != null) {
      view.updateDrivingSide();
    }
  }

  int get drivingSide => this._drivingSide;


  void _addLane(Lane ln) {
    if (ln.direction == FORWARD) {
      forwardLane.add(ln);
    }
    else if (ln.direction == BACKWARD) {
      backwardLane.add(ln);
    }
    else {
      throw new ArgumentError("A lane must have a valid direction when added to road.");
    }
    ln.road = this;
  }

  void addLane(int numForward, int numBackword) {
    for (int i = 0; i < numForward; i++) {
      this._addLane(new Lane(this, FORWARD));
    }
    for (int i = 0; i < numBackword; i++) {
      this._addLane(new Lane(this, BACKWARD));
    }
    updateOnLaneChange();
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

  BacktraceReversibleDBLQ<Lane> _getOppositeLane(Lane lane) {
    if (lane.direction == Road.FORWARD) return backwardLane;
    else return forwardLane;
  }

  /**
   * Called when positions of endPoints are changed
   */
  void updateOnEndChange() {
    length = roadEnd[0].pos.distanceTo(roadEnd[1].pos).toDouble();
    if (view != null) {
      view.updateTransformMatrix();
    }
  }

  void updateOnLaneChange() {
    width = 0.0;
    forwardLane.forEach((l) => width += l.width);
    backwardLane.forEach((l) => width += l.width);
    roadEnd.forEach((e) => e.updateOnLaneChange());
  }

  void update() {
    forwardLane.forEach((l) => l.update());
    backwardLane.forEach((l) => l.update());
  }

  /**
   * Returns true if the request for adding a [vehicle] to a [road] is successful
   *
   * [preferLane] should be [Road.RANDOM_LANE], [Road.INNER_LANE], or [Road.OUTER_LANE].
   */
  bool requestAddVehicle(RoadEnd roadEnd, Vehicle vehicle, int preferLane) {
    //       RHT         LHT
    // Begin                   End
    //0     <----       ---->
    //1     <----       ---->
    //2     ---->       <----
    //3     ---->       <----

    DoubleLinkedQueue<Lane> outwardLane;
    bool isThisLine = false;
    if (preferLane == Road.RANDOM_LANE) isThisLine = world.random.nextBool();

    Function reqAddV = (BacktraceReversibleDBLQ<Lane> outwardLane) {
      if (preferLane == Road.INNER_LANE || isThisLine) {
        if (outwardLane.firstWhere((l) =>
            requestAddVehicleOnLane(roadEnd, vehicle, l), orElse: () => null) != null) {
          return true;
        }
        else {
          // no available lane
          return false;
        }
      }
      else {
        if (outwardLane.lastWhereFromLast((l) =>
            requestAddVehicleOnLane(roadEnd, vehicle, l), orElse: () => null) != null) {
          return true;
        }
        else {
          // no available lane
          return false;
        }
      }
    };

    if (roadEnd.side == Road.BEGIN_SIDE) {
      outwardLane = forwardLane;
    }
    else {
      outwardLane = backwardLane;
    }
    return reqAddV(outwardLane);
  }

  bool requestAddVehicleOnLane(RoadEnd roadEnd, Vehicle vehicle, Lane lane) {
    return lane.requestAddVehicle(vehicle);
  }
}

/**
 * The interface of Road to Joint.
 */
class RoadEnd {
  Vector2 pos;
  /// The road which this roadEnd connects to.
  final Road road;
  /// The index for roadEnd side (can be [Road.BEGIN] or [Road.END]).
  final int side;
  /// Outward means go onto the road,
  /// in order to be consistent with Joint's point of view.
  final BacktraceReversibleDBLQ<Lane> outwardLane;
  /// Inward means leave the road,
  /// in order to be consistent with Joint's point of view.
  final BacktraceReversibleDBLQ<Lane> inwardLane;

  Joint joint;

  RoadEnd(this.road, this.side, this.pos, this.outwardLane, this.inwardLane);

  /**
   * Returns true if the request for adding a [vehicle] to a [road] is successful
   *
   * [preferLane] can be provided, which should be
   * [Road.RANDOM_LANE], [Road.INNER_LANE], or [Road.OUTER_LANE].
   */
  bool requestAddVehicle(Vehicle vehicle, {int preferLane: Road.RANDOM_LANE}) {
    return road.requestAddVehicle(this, vehicle, preferLane);
  }

  void addJoint(Joint joint) {
    if (this.joint != null) {
      this.joint.removeRoadEnd(this);
    }
    this.joint = joint;
    joint.addRoadEnd(this);
  }

  void updateOnLaneChange() {
    if (joint != null) joint.updateOnRoadChange();
  }

  Lane getRandomOutwardLane() {
    var max = outwardLane.length;
    if (max > 0) {
      return outwardLane.elementAt(road.world.random.nextInt(max));
    }
    else {
      return null;
    }
  }

  Iterable<Lane> getAvailableOutwardLane({Vehicle vehicle, List<Lane> excludeLane}) {
    if (excludeLane == null) {
      return outwardLane.where((l) => l.availableForAddVehicle(vehicle: vehicle));
   }
    else {
      return outwardLane.where((l) => (!excludeLane.contains(l)) && l.availableForAddVehicle(vehicle: vehicle));
    }
  }

  bool hasAvailableOutwardLane({Vehicle vehicle}) {
    return outwardLane.any((l) => l.availableForAddVehicle(vehicle: vehicle));
  }

  Iterable<Lane> getLeastQueueOutwardLane({Iterable<Lane> excludeLane}) {
    if (excludeLane == null) {
      int min = outwardLane.fold(outwardLane.first.queue.length, (v, l) =>
          l.queue.length <= v ? l.queue.length : v);
      return outwardLane.where((l) => l.queue.length == min);
   }
    else {
      int min = outwardLane.fold(outwardLane.first.queue.length, (v, l) =>
          l.queue.length <= v ? l.queue.length : v);
      return outwardLane.where((l) => (l.queue.length == min) &&
          (!excludeLane.contains(l)));
    }
  }
}
