part of traffic_simulator;

class World {
  final Set<Road> road = new Set<Road>();
  final Set<Vehicle> vehicle = new Set<Vehicle>();
  final Queue<Vehicle> garage = new Queue<Vehicle>();
  final Set<Joint> joint = new Set<Joint>();
  Random random;
  bool pause = false;

  World({this.random}) {
    if (random == null) {
      random = new Random(new DateTime.now().millisecondsSinceEpoch);
    }
  }

  void addRoad(Iterable<Road> road) {
    for (Road rd in road) {
      rd.world = this;
      this.road.add(rd);
      for (RoadEnd re in rd.roadEnd) {
        if (re.joint != null) {
          re.joint.world = this;
          this.joint.add(re.joint);
        }
      }
    }
  }

  void update(double dt) {
    road.forEach((r) => r.update(dt));
    joint.forEach((j) => j.update(dt));
  }

  Vehicle requestVehicle() {
    if (garage.isEmpty) {
      return new Vehicle(this);
    }
    else {
      return garage.removeLast();
    }
  }
}