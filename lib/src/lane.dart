part of traffic_simulator;

class Lane implements Backtraceable {
  BacktraceReversibleDBLQ<Vehicle> vehicle = new BacktraceReversibleDBLQ<Vehicle>();
  Road road;
  final double width;
  /// Direction of this lane, can be [Road.FORWARD] or [Road.BACKWARD]
  final int direction;

  /// The direction of a lane is always from laneEnd[0] to laneEnd[1]
  List<RoadEnd> laneEnd;
  DoubleLinkedQueueEntry<Lane> entry;
  final Queue<Vehicle> queue = new Queue<Vehicle>();

  Lane(this.road, this.direction, {this.width: 3.5}) {
    if (direction == Road.FORWARD) {
      laneEnd = road.roadEnd;
    }
    else {
      laneEnd = road.roadEnd.reversed.toList(growable: false);
    }
  }

  void draw(Camera camera, Matrix3 transformMatrix) {
    drawLane(camera, transformMatrix);
    for (var veh in vehicle) {
      // align the center of this lane to the x-axis
      Matrix3 tm = preTranslate(transformMatrix, 0.0, width / 2);
      if (this.direction == Road.BACKWARD) {
        // before that, swap the begin and end of the lane
        tm = tm * postTranslate(makeInvertXMatrix3(), road.length, 0.0);
      }
      veh.draw(camera, tm, this);
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
    context.setStrokeColorRgb(0, 0, 0);
    context.lineWidth = 1 / camera.worldPixelPerMeter;
    context.strokeRect(0, 0, road.length, width);

    // lanes are ordered as inner-lane first
    if (entry.nextEntry() == null) {
      if (entry.previousEntry() == null) {
        if (road._getOppositeLane(this).firstEntry() == null) {
          // Single lane road
        }
        else {
          // Only single lane with this direction,
          // Next to its "inside" is an opposite-direction lane
          // Draw: insdie yellow line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
        }
      }
      else {
        // Outermost lane with another same-direction lane inside
        // Draw: inside white line
//        _beginPathInsideLine(context);
        _beginPathInsideDash(context, 2.0, 1.0);
        _strokeWhiteLine(context);
      }
    }
    else {
      if (entry.previousEntry() == null) {
        if (road._getOppositeLane(this).isEmpty) {
          // Outermost lane next to another same-directional lane.
          // This is a one-way traffic road with multiple lanes
//        _beginPathInsideLine(context);
          _beginPathInsideDash(context, 2.0, 1.0);
          _beginPathOutsideDash(context, 2.0, 1.0);
          _strokeWhiteLine(context);
        }
        else {
          // Middle road with its "inside" next to an opposite-direction lane
          // Draw: inside yello line, outside white line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
          _beginPathOutsideDash(context, 2.0, 1.0);
          _strokeWhiteLine(context);
        }
      }
      else {
        // God bless it's just a simple middle lane!
        _beginPathInsideDash(context, 2.0, 1.0);
        _beginPathOutsideDash(context, 2.0, 1.0);
        _strokeWhiteLine(context);
      }
    }

    context.restore();
  }

  void _traceDashAtY(CanvasRenderingContext2D context,
                   double solidLength, double gapLength, double height) {
    double p = 0.0;
    context.moveTo(0, height);
    while (p < road.length) {
      context.lineTo(p += solidLength, height);
      context.moveTo(p += gapLength, height);
    }
  }

  void _traceLineAtY(CanvasRenderingContext2D context, double height) {
    context.moveTo(0, height);
    context.lineTo(road.length, height);
  }

  void _beginPathInsideLine(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((direction == Road.FORWARD && road.drivingHand == Road.RHT) ||
        (direction == Road.BACKWARD && road.drivingHand == Road.LHT)) {
      // Inside is top
      _traceLineAtY(context, 0.0);
    }
    else {
      // Inside is bottom
      _traceLineAtY(context, width);
    }
  }

  void _beginPathInsideDash(CanvasRenderingContext2D context,
                            double solidLength, double gapLength) {
    context.beginPath();
    if ((direction == Road.FORWARD && road.drivingHand == Road.RHT) ||
        (direction == Road.BACKWARD && road.drivingHand == Road.LHT)) {
      // Inside is top
      _traceDashAtY(context, solidLength, gapLength, 0.0);
    }
    else {
      // Inside is bottom
      _traceDashAtY(context, solidLength, gapLength, width);
    }
  }

  void _beginPathOutsideLine(CanvasRenderingContext2D context) {
    context.beginPath();
    if ((direction == Road.FORWARD && road.drivingHand == Road.LHT) ||
        (direction == Road.BACKWARD && road.drivingHand == Road.RHT)) {
      // Outside is top
      _traceLineAtY(context, 0.0);
    }
    else {
      // Outside is bottom
      _traceLineAtY(context, width);
    }
  }

  void _beginPathOutsideDash(CanvasRenderingContext2D context,
                             double solidLength, double gapLength) {
    context.beginPath();
    if ((direction == Road.FORWARD && road.drivingHand == Road.LHT) ||
        (direction == Road.BACKWARD && road.drivingHand == Road.RHT)) {
      // Outside is top
      _traceDashAtY(context, solidLength, gapLength, 0.0);
    }
    else {
      // Outside is bottom
      _traceDashAtY(context, solidLength, gapLength, width);
    }
  }

  void _strokeSingleYellowLine(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(255, 255, 0);
    context.lineWidth = 0.4;
    context.stroke();
  }

  void _strokeWhiteLine(CanvasRenderingContext2D context) {
    context.setStrokeColorRgb(200, 200, 200);
    context.lineWidth = 0.4;
    context.stroke();
  }

  void update() {
    vehicle.forEach((v) => v.update());
  }

  void addFirstVehicle(Vehicle vehicle, {double position}) {
    if (position == null) {
      position = 0.0;
    }
    else {
      if (this.vehicle.isNotEmpty && (position > this.vehicle.first.posOnLane[this])) {
        throw new ArgumentError("The vehicle to addFirst must be added to the most "
            "front end side of a lane");
      }
    }
    vehicle.addLaneOnPosition(this, position);
    this.vehicle.addFirst(vehicle);
  }

  Vehicle removeLastVehicle() {
    return this.vehicle.removeLast();
  }

  bool availableForAddVehicle({Vehicle vehicle}) {
    // TODO: modify for multilane vehicle
    if (queue.isNotEmpty && queue.first != vehicle) {
      return false;
    }

    if (this.vehicle.isEmpty) {
      return true;
    }
    else {
      double space = this.vehicle.first.posOnLane[this] - this.vehicle.first.length;
      if (vehicle != null) {
        space -= vehicle.length;
      }

      if (space > 0) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  int get index {
    return laneEnd.first.outwardLane.toList(growable: false).indexOf(this);
  }
}