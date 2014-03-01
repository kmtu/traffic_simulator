part of traffic_simulator;

class Lane {
  List<Vehicle> vehicle = new List<Vehicle>();
  Road road;
  final double width;
  double halfWidth;

  Lane([this.width = 3.5, this.road]) {
    halfWidth = width / 2;
  }
  
  void draw(Camera camera, Matrix3 transformMatrix) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    Matrix3 tm = transformMatrix * makeTranslateMatrix3(0.0, halfWidth);
    context.transform(tm.entry(0, 0), tm.entry(1, 0),
                      tm.entry(0, 1), tm.entry(1, 1),
                      tm.entry(0, 2), tm.entry(1, 2));
    
    context.save();
    // draw begins
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, -halfWidth, road.distance, width);
    
    context.beginPath();
    context.moveTo(0, -halfWidth);
    context.lineTo(road.distance, -halfWidth);
    context.moveTo(0, halfWidth);
    context.lineTo(road.distance, halfWidth);
    context.setStrokeColorRgb(200, 200, 200);
    context.lineWidth = camera.lineWidth*0.5;
    context.stroke();
    // draw ends
    context.restore();

    for (var veh in vehicle) {
      veh.draw(camera, tm);
    }
    context.restore();
  }
}