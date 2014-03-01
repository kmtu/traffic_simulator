part of traffic_simulator;

class Road extends DoubleLinkedQueue<Lane> {
  List<Joint> _end;
  double _length;
  Matrix3 transformMatrix;
  
  Road(List<Joint> joint) {
    _end = new List<Joint>.from(joint, growable: false) ;
    _length = _end[0]._pos.distanceTo(_end[1]._pos);
    updateTransformMatrix();
  }
  
  double get width {
    double width_ = 0.0;
    for (Lane lane in this) {
      width_ += lane.width;
    }
    return width_;
  }

  @override
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    double width_ = width;

    if (this.isEmpty) {
      //Draw a line if the road contains no lane
      context.save();
      Matrix3 tm = makeTranslateMatrix3(0.0, -width_/2);
      tm.multiply(transformMatrix);
      context.transform(tm.entry(0, 0), tm.entry(1, 0),
                        tm.entry(0, 1), tm.entry(1, 1),
                        tm.entry(0, 2), tm.entry(1, 2));
      context.beginPath();
      context.moveTo(0, width_ / 2);
      context.lineTo(_length, width_ / 2);
      context.setStrokeColorRgb(255, 0, 0, 0.5);
      context.lineWidth = 10;
      context.stroke();
      context.restore();

    }
    else {
      for (Lane lane in this) {
        context.save();
        lane.draw(camera);
        context.restore();
      }
    }
  }
  
  void updateTransformMatrix() {
    // rotate first then translate
    Vector2 d = _end[1]._pos - _end[0]._pos;
    double angle = atan2(d.y, d.x);
    transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = translateMatrix3(transformMatrix, _end[0]._pos.x, _end[0]._pos.y);
  }
}