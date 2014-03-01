part of traffic_simulator;

class Joint {
  List<Road> road = new List<Road>();
  Vector2 _pos;
  double radius;
  
  Joint(this._pos);
  
  void setPos(Vector2 pos) {
    _pos = pos;
    if (road.length > 0) {
      for (Road rd in road) {
        rd.updateOnJointChange();
      }
    }
  }
  
  void addRoad(Road road) {
    this.road.add(road);
    updateOnRoadChange();
  }
  
  void updateOnRoadChange() {
    radius = 0.0;
    if (road.length > 0) {
      for (Road rd in road) {
        if (rd.width / 2 > radius) {
          radius = rd.width / 2;
        }
      }
    }
  }
  
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    context.beginPath();
    context.arc(_pos.x, _pos.y, radius, 0, 2*PI);
    context.fillStyle = "grey";
    context.fill();
    context.restore();
  }
}

class SourceJoint extends Joint {
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
  
  SourceJoint(Vector2 pos) : super(pos);
  
  void update(GameLoopHtml gameLoop) {
    gameLoop.addTimer(addVehicle, 1, periodic: true);
  }
  
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    context.beginPath();
    context.arc(_pos.x, _pos.y, radius, 0, 2*PI);
    context.fillStyle = "orange";
    context.fill();
    
    context.restore();
  }
}
