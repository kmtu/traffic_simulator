part of traffic_simulator;

class Lane implements Controller {
  LaneModel model;
  LaneView view;

  Lane(Road road, int direction, {double width}) {
    if (width == null) width = 3.5;
    model = new LaneModel(road, direction, width);

    if (direction == Road.FORWARD) {
      model.laneEnd = model.road.roadEnd;
    }
    else {
      model.laneEnd = road.roadEnd.reversed.toList(growable: false);
    }
  }

  int get direction => model.direction;
  set road(Road road) => model.road = road;
  Road get road => model.road;
  double get width => model.width;
  DoubleLinkedQueueEntry<Lane> get entry => model.entry;
  set entry(DoubleLinkedQueueEntry<Lane> entry) => model.entry = entry;
  Queue<Vehicle> get queue => model.queue;

  void render() => view.render();

  void addView(LaneView view) {
    this.view = view;
    view.update();
  }

  void update() {
    model.vehicle.forEach((v) => v.update());
  }

  void addFirstVehicle(Vehicle vehicle) {
    vehicle.pos = 0.0;
    vehicle.lane = this;
    model.vehicle.addFirst(vehicle);
  }

}