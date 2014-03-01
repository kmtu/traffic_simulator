part of traffic_simulator;

class Joint {
  List<Road> road = new List<Road>();
  Vector2 _pos;
  
  Joint(this._pos);
  
  void setPos(Vector2 pos) {
    _pos = pos;
    if (road.length > 0) {
      for (Road rd in road) {
        rd.updateEnds();
      }
    }
  }
}

class SourceJoint extends Joint {
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
  
  SourceJoint(Vector2 pos) : super(pos);
  
  void update(double dt) {
    if (road.length > 0) {
      
    }
  }
}
