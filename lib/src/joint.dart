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
        if (rd.distance > radius) {
          radius = rd.distance;
        }
      }
    }
  }
  
  void draw(Camera camera) {
  }
}

class SourceJoint extends Joint {
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
  
  SourceJoint(Vector2 pos) : super(pos);
  
  void update(GameLoopHtml gameLoop) {
    if (road.length > 0) {
      
    }
  }
}
