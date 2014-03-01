part of traffic_simulator;

class Joint {
  List<Road> road = new List<Road>();
  Vector2 _pos;
  
  Joint(this._pos);
  
  void setPos(Vector2 pos) {
    _pos = pos;
    if (road.length > 0) {
      for (Road rd in road) {
        rd.updateTransformMatrix();
      }
    }
  }
}

class SourceJoint extends Joint {
  SourceJoint(Vector2 pos) : super(pos);
}
