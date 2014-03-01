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
  
  Road(List<Joint> joint, {int direction: RHT}) {
    _end = new List<Joint>.from(joint, growable: false);
    for (Joint j in joint) {
      j.road.add(this);
    }
    updateEnds();
  }
  
  double get width {
    double width_ = 0.0;
    for (Lane lane in this) {
      width_ += lane.width;
    }
    return width_;
  }
  
  @override
  void add(Lane lane) {
    if ((lane.direction == FORWARD && this.direction == RHT)||
        (lane.direction == BACKWARD && this.direction == LHT)) {
      super.addLast(lane);
    }
    else {
      super.addFirst(lane);
    }
    lane.road = this;
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
      for (Lane lane in this) {
        context.save();
        Matrix3 tm = transformMatrix * makeTranslateMatrix3(0.0, -halfRoadWidth + cumWidth_);
        lane.draw(camera, tm);
        context.restore();
        cumWidth_ += lane.width;
      }
    }
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
    context.lineWidth = camera.lineWidth;
    context.stroke();
    context.restore();
  }
  
  void updateEnds() {
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
  
  void update(GameLoopHtml gameLoop) {
    if (this.isNotEmpty) {
      for (Lane lane in this) {
        lane.update(gameLoop);
      }
    }
  }
}
