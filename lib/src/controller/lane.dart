part of traffic_simulator;

class LaneController implements Controller {
  Lane _model;
  LaneView view;

  LaneController(Road road, int direction, {double width}) {
    if (width == null) width = 3.5;
    _model = new Lane(road, direction, width);

    if (direction == Road.FORWARD) {
      _model.laneEnd = _model.road.roadEnd;
    }
    else {
      _model.laneEnd = road.roadEnd.reversed.toList(growable: false);
    }
  }

  int get direction => _model.direction;
  set road(Road road) => _model.road = road;
  Road get road => _model.road;
  double get width => _model.width;
  DoubleLinkedQueueEntry<LaneController> get entry => _model.entry;
  set entry(DoubleLinkedQueueEntry<LaneController> entry) => _model.entry = entry;
  Queue<VehicleController> get queue => _model.queue;

  void update() {
    _model.vehicle.forEach((v) => v.update());
  }

  void addFirstVehicle(VehicleController vehicle) {
    vehicle.pos = 0.0;
    vehicle.lane = this;
    _model.vehicle.addFirst(vehicle);
  }

}