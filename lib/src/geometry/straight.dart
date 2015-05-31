part of traffic_simulator;

class Straight extends Line{

  Straight(Vector2 end0, Vector2 end1): super(end0, end1);

  double get length => vector.length;
  Vector2 get center => getPoint(0.5);

  Vector2 getPoint(double t) {
    return ends[0] + vector * t;
  }

  Straight subLine(double x, double y) {
    var vector = this.vector;
    var end0 = ends[0] + vector * x;
    var end1 = ends[0] + vector * y;
    return new Straight(end0, end1);
  }
}