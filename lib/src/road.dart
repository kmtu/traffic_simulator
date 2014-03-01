part of traffic_simulator;

class Road extends DoubleLinkedQueue<Lane> {  
  static const int FORWARD = 0;
  static const int BACKWARD = 1;
  static const int RHT = 10; //Right-Hand Traffic
  static const int LHT = 11; //Left-Hand Traffic

  List<Joint> _end;
  double distance;
  Matrix3 transformMatrix;
  int direction;
  double width = 0.0;
  
  Road(List<Joint> joint, {int numForwardLane: 1, int numBackwardLane: 1, int direction: RHT}) {
    _end = new List<Joint>.from(joint, growable: false);
    updateOnJointChange();
    addLane(numForwardLane, numBackwardLane);
    for (Joint j in joint) {
      j.addRoad(this);
    }
  }
  
  @override
  void add(Lane lane) {
    if ((lane.direction == FORWARD && this.direction == RHT)||
        (lane.direction == BACKWARD && this.direction == LHT)) {
      super.addLast(lane);
      lane.entry = this.lastEntry();
    }
    else {
      super.addFirst(lane);
      lane.entry = this.firstEntry();
    }
    lane.road = this;
    updateOnLaneChange();
  }
  
  Road addLane(int numForward, int numBackword) {
    for (int i = 0; i < numForward; i++) {
      this.add(new Lane(this, direction: FORWARD));
    }
    for (int i = 0; i < numBackword; i++) {
      this.add(new Lane(this, direction: BACKWARD));
    }
    return this;
  }
  
  int get numLane => length;
  
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;

    if (this.isEmpty) {
      drawRoadLine(camera);
    }
    else {
      double cumWidth_ = 0.0;
      double halfRoadWidth = width / 2;
      forEachEntry((laneEntry){
        context.save();
        Matrix3 tm = transformMatrix * makeTranslateMatrix3(0.0, -halfRoadWidth + cumWidth_);
        laneEntry.element.draw(camera, tm);
        context.restore();
        cumWidth_ += laneEntry.element.width;        
      });
      drawRoadBoundary(camera);
    }
  }
  
  void drawRoadBoundary(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();

    // draw as if the center of the road aligns to the x-axis
    double halfRoadWidth = width / 2;
    Matrix3 tm = transformMatrix * makeTranslateMatrix3(0.0, 0.0);
    context.transform(tm.entry(0, 0), tm.entry(1, 0),
                      tm.entry(0, 1), tm.entry(1, 1),
                      tm.entry(0, 2), tm.entry(1, 2));
  
    context.beginPath();
    
    // draw top boundary line
    context.moveTo(0, -halfRoadWidth);
    context.lineTo(distance, -halfRoadWidth);
    
    // draw top boundary line
    context.moveTo(0, halfRoadWidth);
    context.lineTo(distance, halfRoadWidth);
    
    context.setStrokeColorRgb(100, 100, 100);
    context.lineWidth = 1;
    context.stroke();
    
    context.restore();
  }
  
  void drawRoadLine(Camera camera) {
    //Draw a line if the road contains no lane
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    context.transform(transformMatrix.entry(0, 0), transformMatrix.entry(1, 0),
                      transformMatrix.entry(0, 1), transformMatrix.entry(1, 1),
                      transformMatrix.entry(0, 2), transformMatrix.entry(1, 2));
    context.beginPath();
    context.moveTo(0, 0);
    context.lineTo(distance, 0);
    context.setStrokeColorRgb(255, 0, 0, 0.5);
    context.lineWidth = 1;
    context.stroke();
    context.restore();
  }
  
  void updateOnJointChange() {
    // call when states of ends are changed
    distance = _end[0]._pos.distanceTo(_end[1]._pos).toDouble();
    
    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation. 
    Vector2 d = _end[1]._pos - _end[0]._pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = translateMatrix3(transformMatrix, _end[0]._pos.x, _end[0]._pos.y);
  }
  
  void updateOnLaneChange() {
    width = 0.0;
    for (Lane lane in this) {
      width += lane.width;
    }
    for (Joint joint in _end) {
      joint.updateOnRoadChange();
    }
  }
  
  void update(GameLoopHtml gameLoop) {
    forEachEntry((laneEntry){
      laneEntry.element.update(gameLoop);
    });
  }
}
