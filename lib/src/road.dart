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
  
  /// Lanes which direction are [Road.FORWARD]
  /// First added will be drawn as inner lanes
  final BacktraceReversibleDBLQ<Lane> forwardLane = new BacktraceReversibleDBLQ<Lane>();
  
  /// Lanes which direction are [Road.BACKWARD]
  /// First added will be drawn as inner lanes
  final BacktraceReversibleDBLQ<Lane> backwardLane = new BacktraceReversibleDBLQ<Lane>();
  
  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<Lane> _upperLane;
  /// Lanes in the upper part of this road. For drawing purpose.
  DoubleLinkedQueue<Lane> _lowerLane;
  
  /// Position of the two [roadEnd] of this road
  final List<RoadEnd> roadEnd = new List<RoadEnd>(2);
  
  /// Length of this road in meters
  double length;
  Matrix3 transformMatrix;
  /// Right-Hand Traffic or Left-Hand Traffic.
  /// Can be [Road.RHT] or [Road.LHT].
  int drivingHand;
  
  double width = 0.0;
  double boundaryLineWidth = 1.0;
  
  TrafficSimulator world;
 
  Road(List<Vector2> end, {int numForwardLane: 1, int numBackwardLane: 1, this.drivingHand: RHT}) {
    if (end.length != 2) {
      throw new ArgumentError("Road: there must be two and only two ends in a road.");
    }
    roadEnd[0] = new RoadEnd(this, Road.BEGIN_SIDE, end[0], forwardLane, backwardLane);
    roadEnd[1] = new RoadEnd(this, Road.END_SIDE, end[1], backwardLane, forwardLane);
    updateOnEndChange();
    addLane(numForwardLane, numBackwardLane);
  }
  
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
    updateOnLaneChange();
  }
  
  Road addLane(int numForward, int numBackword) {
    for (int i = 0; i < numForward; i++) {
      this._addLane(new Lane(this, direction: FORWARD));
    }
    for (int i = 0; i < numBackword; i++) {
      this._addLane(new Lane(this, direction: BACKWARD));
    }
    return this;
  }
    
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    if (forwardLane.isEmpty && backwardLane.isEmpty) {
      _drawMiddleLine(camera);
    }
    else {
      _drawUpperLane(camera, _upperLane);
      _drawLowerLane(camera, _lowerLane);
      _drawBoundary(camera);
    }
    context.restore();    
  }
  
  void _drawUpperLane(Camera camera, BacktraceReversibleDBLQ<Lane> lane) {
    double cumWidth_ = 0.0;
    double halfTotalLaneWidth = width / 2 - boundaryLineWidth / 2;
    // draw from outer lane
    lane.forEachEntryFromLast((laneEntry){
      laneEntry.element.draw(camera, 
          preTranslate( transformMatrix, 0.0, -halfTotalLaneWidth + cumWidth_));
      cumWidth_ += laneEntry.element.width;        
    });
  }

  void _drawLowerLane(Camera camera, BacktraceReversibleDBLQ<Lane> lane) {
    double cumWidth_ = 0.0;
    double halfTotalLaneWidth = width / 2 - boundaryLineWidth / 2;
    // draw from outer lane
    lane.forEachEntryFromLast((laneEntry){
      cumWidth_ += laneEntry.element.width;        
      laneEntry.element.draw(camera, 
          preTranslate( transformMatrix, 0.0, halfTotalLaneWidth - cumWidth_));
    });
  }
  
  void _drawBoundary(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();

    transformContext(context, transformMatrix);    
    // draw as if the center of the road aligns to the x-axis
    
    context.beginPath();
    
    // draw top boundary line
    double totalHalfLaneWidth = width / 2 - boundaryLineWidth / 2;
    context.moveTo(0, -totalHalfLaneWidth);
    context.lineTo(length, -totalHalfLaneWidth);
    
    // draw bottom boundary line
    context.moveTo(0, totalHalfLaneWidth);
    context.lineTo(length, totalHalfLaneWidth);
    
    context.setStrokeColorRgb(100, 100, 100);
    context.lineWidth = boundaryLineWidth;
    context.stroke();
    
    context.restore();
  }
  
  void _drawMiddleLine(Camera camera) {
    //Draw a line if the road contains no lane
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    transformContext(context, transformMatrix);
    // draw as if the center of the road aligns to the x-axis

    context.beginPath();
    context.moveTo(0, 0);
    context.lineTo(length, 0);
    context.setStrokeColorRgb(255, 0, 0, 0.5);
    context.lineWidth = 1;
    context.stroke();
    context.restore();
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

    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation. 
    Vector2 d = roadEnd[1].pos - roadEnd[0].pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = postTranslate(transformMatrix, roadEnd[0].pos.x, roadEnd[0].pos.y);
  }
  
  void updateOnLaneChange() {
    width = boundaryLineWidth;
    forwardLane.forEach((l) => width += l.width);
    backwardLane.forEach((l) => width += l.width);

    if (drivingHand == Road.RHT) {
      _upperLane = backwardLane;
      _lowerLane = forwardLane;
      
    }
    else {
      _upperLane = forwardLane;
      _lowerLane = backwardLane;
    }
    
    roadEnd.forEach((e) => e.updateOnLaneChange());
  }
  
  void update() {
    forwardLane.forEach((l) => l.update());
    backwardLane.forEach((l) => l.update());
  }
  
  void addJoint(Joint joint, int side) {
    roadEnd[side].addJoint(joint);
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
}
