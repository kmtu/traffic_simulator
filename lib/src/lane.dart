part of traffic_simulator;

class Lane {
  List<Vehicle> vehicle = new List<Vehicle>();
  Road road;
  final double width;
  double halfWidth;
  int direction;
  DoubleLinkedQueueEntry entry;

  Lane(this.road, {this.width: 3.5, this.direction: Road.FORWARD}) {
    halfWidth = width / 2;
  }
  
  void draw(Camera camera, Matrix3 transformMatrix) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    // align the center of this lane to x-axis
    Matrix3 tm = transformMatrix * makeTranslateMatrix3(0.0, halfWidth);
    context.transform(tm.entry(0, 0), tm.entry(1, 0),
                      tm.entry(0, 1), tm.entry(1, 1),
                      tm.entry(0, 2), tm.entry(1, 2));
    
    // draw begins
    context.save();
    
    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, -halfWidth, road.distance, width);

    // draw lane division line
    Function drawLineByNeighborLane = (Lane neighbor) {
      if (neighbor != null) {
        if (neighbor.direction != this.direction) {
          context.setStrokeColorRgb(255, 255, 0);
          context.lineWidth = 0.4;
        }
        else {
          context.setStrokeColorRgb(200, 200, 200);
          context.lineWidth = 0.2;
        }
        context.stroke();
      }
    }; 
    
    context.beginPath();
    context.moveTo(0, -halfWidth);
    context.lineTo(road.distance, -halfWidth);
    Lane prev_;
    if (entry.previousEntry() != null) {
      prev_ = entry.previousEntry().element;
    }
    drawLineByNeighborLane(prev_);

    context.beginPath();
    context.moveTo(0, halfWidth);
    context.lineTo(road.distance, halfWidth);
    Lane next_;
    if (entry.nextEntry() != null) {
      Lane next_ = entry.nextEntry().element;
    }
    drawLineByNeighborLane(next_);

    // draw ends
    context.restore();

    for (var veh in vehicle) {
      veh.draw(camera, tm);
    }
    context.restore();
  }
  
  void update(GameLoopHtml gameLoop) {
    for (var veh in vehicle) {
      veh.update(gameLoop);
    }
  }
}