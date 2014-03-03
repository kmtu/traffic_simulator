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
    drawLane(camera, transformMatrix);
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
  
  void drawLane(Camera camera, Matrix3 transformMatrix) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    
    // top of this lane is aligned to x-axis
    transformContext(context, transformMatrix);
      
    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, 0, road.length, width);

    // lanes are ordered as outer-lane first
    if (entry.previousEntry() == null) {
      if (entry.nextEntry() == null) {
        if (road._getOppositeLane(this).last == null) {
          // Single lane road
        }
        else {
          // Only single lane with this direction,
          // Next to its "inside" is an opposite-direction lane
          // TODO: insdie yellow line
          _traceInsidePath(context);
          _strokeSingleYelloLine(context);
        }
      }
      else {
        // Outermost lane with another same-direction lane inside
        // TODO: inside white line
        _traceInsidePath(context);
        _strokeWhiteLine(context);
      }
    }
    else {
      if (entry.nextEntry() == null) {
        if (road._getOppositeLane(this).last == null) {
          // Outermost lane next to another same-directional lane.
          // This is a one-way traffic road with multiple lanes
          // TODO: inside white line
          _traceInsidePath(context);
          _strokeWhiteLine(context);
        }
        else {
          // Middle road with its "inside" next to an opposite-direction lane
          // TODO: inside yello line, outside white line
          _traceInsidePath(context);
          _strokeSingleYelloLine(context);
          _traceOutsidePath(context);
          _strokeWhiteLine(context);
        }
      }
      else {
        // God bless it's just a simple middle lane!
        _traceInsidePath(context);
        _traceOutsidePath(context);
        _strokeWhiteLine(context);
      }
    }
    
    context.restore();
  }
  
  void _traceInsidePath(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((direction == Road.FORWARD && road.drivingHand == Road.RHT) ||
        (direction == Road.BACKWARD && road.drivingHand == Road.LHT)) {
      // Inside is top
      context.moveTo(0, 0);
      context.lineTo(road.length, 0);
    }
    else {
      // Inside is bottom
      context.moveTo(0, width);      
      context.lineTo(road.length, width);
    }
  }
  
  void _traceOutsidePath(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((direction == Road.FORWARD && road.drivingHand == Road.LHT) ||
        (direction == Road.BACKWARD && road.drivingHand == Road.RHT)) {
      // Outside is top
      context.moveTo(0, 0);
      context.lineTo(road.length, 0);
    }
    else {
      // Outside is bottom
      context.moveTo(0, width);      
      context.lineTo(road.length, width);
    }
  }

  void _strokeSingleYelloLine(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(255, 255, 0);
    context.lineWidth = 0.4;
    context.stroke();
  }
  
  void _strokeWhiteLine(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(200, 200, 200);
    context.lineWidth = 0.2;
    context.stroke();
  }
  
  void update() {
    vehicle.forEach((v) => v.update());
  }
  
  bool requestAddVehicle(Vehicle vehicle) {
    // TODO: add checking condition if a vehicle can be added
    vehicle.pos = 0.0;
    vehicle.lane = this;
    this.vehicle.add(vehicle);
    return true;
  }
}