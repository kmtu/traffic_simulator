part of traffic_simulator;

class Lane {
  DoubleLinkedQueue<Vehicle> vehicle = new DoubleLinkedQueue<Vehicle>();
  Road road;
  final double width;
  double halfWidth;
  int direction;
  DoubleLinkedQueueEntry<Lane> entry;

  Lane(this.road, {this.width: 3.5, this.direction: Road.FORWARD}) {
    halfWidth = width / 2;
  }
  
  void draw(Camera camera, Matrix3 transformMatrix) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    // align the center of this lane to x-axis
    Matrix3 tm = preTranslate(transformMatrix, 0.0, halfWidth);
    transformContext(context, tm);
        
    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, -halfWidth, road.length, width);

    // draw lane division line
    Function drawLineByNeighborLane = (Lane neighbor) {
        if (neighbor.direction != this.direction) {
          context.setStrokeColorRgb(255, 255, 0);
          context.lineWidth = 0.4;
        }
        else {
          context.setStrokeColorRgb(200, 200, 200);
          context.lineWidth = 0.2;
        }
        context.stroke();
    }; 
    
    context.beginPath();
    context.moveTo(0, -halfWidth);
    context.lineTo(road.length, -halfWidth);
    if (entry.previousEntry() != null) {
      drawLineByNeighborLane(entry.previousEntry().element);
    }

    context.beginPath();
    context.moveTo(0, halfWidth);
    context.lineTo(road.length, halfWidth);
    if (entry.nextEntry() != null) {
      drawLineByNeighborLane(entry.nextEntry().element);
    }

    context.restore();

    for (var veh in vehicle) {
      veh.draw(camera, tm);
    }
  }
  
  void update(GameLoopHtml gameLoop) {
    for (var veh in vehicle) {
      veh.update(gameLoop);
    }
  }
  
  void addVehicle(Vehicle veh) {
    this.vehicle.add(veh);
  }
}