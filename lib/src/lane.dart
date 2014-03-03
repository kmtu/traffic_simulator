part of traffic_simulator;

class Lane {
  DoubleLinkedQueue<Vehicle> vehicle = new DoubleLinkedQueue<Vehicle>();
  Road road;
  final double width;
  /// Direction of this lane, can be [Road.FORWARD] or [Road.BACKWARD]
  int direction;
  DoubleLinkedQueueEntry<Lane> entry;

  Lane(this.road, {this.width: 3.5, this.direction: Road.FORWARD}) ;
  
  void draw(Camera camera, Matrix3 transformMatrix) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    // top of this lane is aligned to x-axis
    transformContext(context, transformMatrix);
      
    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, 0, road.length, width);

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
    
    // draw top line
    context.beginPath();
    context.moveTo(0, 0);
    context.lineTo(road.length, 0);
    if (entry.previousEntry() != null) {
      drawLineByNeighborLane(entry.previousEntry().element);
    }

    // draw bottom line
    context.beginPath();
    context.moveTo(0, width);
    context.lineTo(road.length, width);
    if (entry.nextEntry() != null) {
      drawLineByNeighborLane(entry.nextEntry().element);
    }

    context.restore();

    for (var veh in vehicle) {
      // align the center of this lane to the x-axis
      Matrix3 tm = preTranslate(transformMatrix, 0.0, width / 2);
      if (this.direction == Road.BACKWARD) {
        // before that, swap the begin and end of the lane
        tm = tm * postTranslate(makeInvertXMatrix3(), road.length, 0.0);
      }
      veh.draw(camera, tm);
    }
  }
  
  void update() {
    for (var veh in vehicle) {
      veh.update();
    }
  }
  
  bool requestAddVehicle(Vehicle vehicle) {
    // TODO: add checking condition if a vehicle can be added
    vehicle.pos = 0.0;
    vehicle.lane = this;
    this.vehicle.add(vehicle);
    return true;
  }
}