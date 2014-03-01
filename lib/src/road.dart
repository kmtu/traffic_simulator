part of traffic_simulator;

class Road {  
  static const int FORWARD = 0; // from joint[0] to joint[1]
  static const int BACKWARD = 1; // from joint[1] to joint[0]
  static const int RHT = 10; //Right-Hand Traffic
  static const int LHT = 11; //Left-Hand Traffic
  double boundaryLineWidth = 1.0;
  DoubleLinkedQueue<Lane> lane = new DoubleLinkedQueue<Lane>();

  List<Joint> joint;
  double length;
  Matrix3 transformMatrix;
  int drivingDirection;
  double width = 0.0;
  int numForwardLane = 0;
  int numBackwardLane = 0;
 
  Road(List<Joint> jj, {int numForwardLane: 1, int numBackwardLane: 1, int direction: RHT}) {
    joint = new List<Joint>.from(jj, growable: false);
    updateOnJointChange();
    addLane(numForwardLane, numBackwardLane);
    for (Joint j in jj) {
      j.addRoad(this);
    }
  }
  
  void _addLane(Lane ln) {
    if ((ln.direction == FORWARD && this.drivingDirection == RHT)||
        (ln.direction == BACKWARD && this.drivingDirection == LHT)) {
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
  
  void updateOnJointChange() {
    // call when states of ends are changed
    length = joint[0]._pos.distanceTo(joint[1]._pos).toDouble();
    
    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation. 
    Vector2 d = joint[1]._pos - joint[0]._pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = postTranslate(transformMatrix, joint[0]._pos.x, joint[0]._pos.y);
  }
  
  void updateOnLaneChange() {
    width = boundaryLineWidth;
    for (Lane ln in lane) {
      width += ln.width;
    }
    for (Joint joint in joint) {
      joint.updateOnRoadChange();
    }
  }
  
  void update(GameLoopHtml gameLoop) {
    lane.forEachEntry((laneEntry){
      laneEntry.element.update(gameLoop);
    });
  }
  
  void addVehicleOnLane(Vehicle) {
    
  }
}
