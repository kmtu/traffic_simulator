part of traffic_simulator;

class Curve extends Line {
  static const NUM_CURVE_SAMPLE_POINTS = 10;
  final List<Vector2> ctps = new List<Vector2>(2);

  Curve(Vector2 end0, Vector2 ctp0, Vector2 ctp1, Vector2 end1)
      : super(end0, end1) {
    ctps[0] = ctp0;
    ctps[1] = ctp1;
  }

  double get length {
    var _length = 0.0;
    var prevPoint = null;
    for (var i = 0; i < NUM_CURVE_SAMPLE_POINTS; i++) {
      var point = getPoint(i / NUM_CURVE_SAMPLE_POINTS);
      if (prevPoint != null) {
        _length += point.distanceTo(prevPoint);
      }
      prevPoint = point;
    }
    return _length;
  }

  Vector2 getPoint(double t) {
    var tm = 1 - t;
    var tm2 = tm * tm;
    var tm3 = tm * tm2;
    var t2 = t * t;
    var t3 = t * t2;
    return ends[0] * tm3 +
        ctps[0] * 3.0 * tm2 * t +
        ctps[1] * 3.0 * tm * t2 +
        ends[1] * t3;
  }

  double angleAt(double t) {
    var tm = 1 - t;
    var tm2 = tm * tm;
    var t2 = t * t;
    var vec = (ctps[0] - ends[0]) * 3.0 * tm2 +
        (ctps[1] - ctps[0]) * 6.0 * tm * t +
        (ends[1] - ctps[1]) * 3.0 * t2;
    return Geometry.angle(vec);
  }
}
