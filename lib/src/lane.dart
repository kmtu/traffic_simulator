part of traffic_simulator;

class Lane implements Backtraceable {
  LaneView view;
  BacktraceReversibleDBLQ<Vehicle> vehicle = new BacktraceReversibleDBLQ<Vehicle>();
  Road road;
  final double width;
  /// Direction of this lane, can be [Road.FORWARD] or [Road.BACKWARD]
  final int direction;

  /// The direction of a lane is always from laneEnd[0] to laneEnd[1]
  final List<RoadEnd> laneEnd = new List<RoadEnd>(2);
  DoubleLinkedQueueEntry<Lane> entry;
  final Queue<Vehicle> queue = new Queue<Vehicle>();

  Lane(this.road, this.direction, {this.width: 3.5, this.view}) {
    if (direction == Road.FORWARD) {
      laneEnd.setAll(0, road.roadEnd);
    }
    else {
      laneEnd.setAll(0, road.roadEnd.reversed);
    }

    if (view == null) {
      view = new LaneView(this);
    }
  }

  void update() {
    vehicle.forEach((v) => v.update());
  }

  void addFirstVehicle(Vehicle vehicle) {
    vehicle.pos = 0.0;
    vehicle.lane = this;
    vehicle.view.update();
    this.vehicle.addFirst(vehicle);
  }

  Vehicle removeLastVehicle() {
    return this.vehicle.removeLast();
  }

  bool availableForAddVehicle({Vehicle vehicle}) {
    if (queue.isNotEmpty && queue.first != vehicle) {
      return false;
    }

    if (this.vehicle.isEmpty) {
      return true;
    }
    else {
      double space = this.vehicle.first.pos - this.vehicle.first.length;
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