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
  
  double boundaryLineWidth = 1.0;
  DoubleLinkedQueue<Lane> lane = new DoubleLinkedQueue<Lane>();
  /// Position of the two [roadEnd] of this road
  final List<RoadEnd> roadEnd = new List<RoadEnd>(2);
  double length;
  Matrix3 transformMatrix;
  /// Right-Hand Traffic or Left-Hand Traffic.
  /// Can be [Road.RHT] or [Road.LHT].
  int drivingHand;
  double width = 0.0;
  int numForwardLane = 0;
  int numBackwardLane = 0;
  TrafficSimulator world;
 
  Road(List<Vector2> end, {this.numForwardLane: 1, this.numBackwardLane: 1, this.drivingHand: RHT}) {
    if (end.length != 2) {
      throw new ArgumentError("Road: there must be two and only two ends in a road.");
    } 
    roadEnd[0] = new RoadEnd(this, Road.BEGIN_SIDE, end[0]);
    roadEnd[1] = new RoadEnd(this, Road.END_SIDE, end[1]);
    updateOnEndChange();
    addLane(numForwardLane, numBackwardLane);
  }
  
  void _addLane(Lane ln) {
    if ((ln.direction == FORWARD && this.drivingHand == RHT) ||
        (ln.direction == BACKWARD && this.drivingHand == LHT)) {
      lane.addLast(ln);
      ln.entry = lane.lastEntry();
    }
    else {
      lane.addFirst(ln);
      ln.entry = lane.firstEntry();
    }
    ln.road = this;
    updateOnLaneChange();
  }
  
  Road addLane(int numForward, int numBackword) {
    numForwardLane += numForward;
    for (int i = 0; i < numForward; i++) {
      this._addLane(new Lane(this, direction: FORWARD));
    }
    numBackwardLane += numBackword;
    for (int i = 0; i < numBackword; i++) {
      this._addLane(new Lane(this, direction: BACKWARD));
    }
    return this;
  }
    
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();       
    if (lane.isEmpty) {
      drawRoadLine(camera);
    }
    else {
      double cumWidth_ = 0.0;
      double halfTotalLaneWidth = width / 2 - boundaryLineWidth / 2;
      lane.forEachEntry((laneEntry){
        laneEntry.element.draw(camera, preTranslate( transformMatrix, 0.0, -halfTotalLaneWidth + cumWidth_));
        cumWidth_ += laneEntry.element.width;        
      });
      drawRoadBoundary(camera);
    }
    context.restore();
    
    // Draw joints on the roadEnds
    roadEnd.forEach((r) => r.drawJoint(camera));
  }
  
  void drawRoadBoundary(Camera camera) {
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
  
  void drawRoadLine(Camera camera) {
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
    for (Lane ln in lane) {
      width += ln.width;
    }
    for (var end in roadEnd) {
      if (end.joint != null) end.joint.updateOnRoadChange();
    }
  }
  
  void update() {
    lane.forEachEntry((laneEntry){
      laneEntry.element.update();
    });
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
    DoubleLinkedQueue<Lane> outwardLane;
    //       RHT         LHT
    // Begin                   End
    //0     <----       ---->
    //1     <----       ---->
    //2     ---->       <----
    //3     ---->       <----
    
    bool isThisLine = false;
    if (preferLane == Road.RANDOM_LANE) isThisLine = world.random.nextBool();
    
    // Now let's assume RHT
    if (roadEnd.side == Road.BEGIN_SIDE) {
      outwardLane = new DoubleLinkedQueue<Lane>.from(lane.where((l) => l.direction == Road.FORWARD));
      // Inner lanes are the first in list
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
        // 
        // HERE IS BE THE PROBLEM !!!!
        // lastWhere() may actually still start from the beginning and thus  
        //
        if (outwardLane.lastWhere((l) => 
            requestAddVehicleOnLane(roadEnd, vehicle, l), orElse: () => null) != null) {
          return true;
        }
        else {
          // no available lane
          return false;
        }
      }
    }
    else {
      outwardLane = new DoubleLinkedQueue<Lane>.from(lane.where((l) => l.direction == Road.BACKWARD));
      // Outer lanes are the first in list
      if (preferLane == Road.INNER_LANE || isThisLine) {
        // 
        // HERE IS BE THE PROBLEM !!!!!
        // lastWhere() may actually still start from the beginning and thus  
        //
        if (outwardLane.lastWhere((l) => 
            requestAddVehicleOnLane(roadEnd, vehicle, l), orElse: () => null) != null) {
          return true;
        }
        else {
          // no available lane
          return false;
        }
      }
      else {
        if (outwardLane.firstWhere((l) => 
            requestAddVehicleOnLane(roadEnd, vehicle, l), orElse: () => null) != null) {
          return true;
        }
        else {
          // no available lane
          return false;
        }
      }
    }
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
  Joint joint;
  
  RoadEnd(this.road, this.side, this.pos);
  
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
  
  void drawJoint(Camera camera) {
    if (joint != null) joint.drawWithRoadEnd(camera, this);
  }
}
