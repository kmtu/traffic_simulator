part of traffic_simulator;

abstract class Line {
  final List<Vector2> ends = new List<Vector2>(2);

  Line(Vector2 end0, Vector2 end1) {
    ends[0] = end0;
    ends[1] = end1;
  }

  Vector2 get vector => ends[1] - ends[0];

  Vector2 getPoint(double t);
  double get length;
  double get angle => Geometry.angle(vector);
}