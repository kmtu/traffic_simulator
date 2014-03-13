part of traffic_simulator;

class World {
  WorldView view;
  final Set<Road> road = new Set<Road>();
  final Set<Vehicle> vehicle = new Set<Vehicle>();
  final Queue<Vehicle> garage = new Queue<Vehicle>();
  final Set<Joint> joint = new Set<Joint>();
  GameLoopHtml gameLoop;
  double dtUpdate;
  Random random;
  bool pause = false;

  World(this.gameLoop, {this.random, this.view}) {
    if (random == null) {
      random = new Random(new DateTime.now().millisecondsSinceEpoch);
    }
    dtUpdate = gameLoop.dt;
    if (view == null) {
      view = new WorldView(this);
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

  void update() {
    road.forEach((r) => r.update());
    joint.forEach((j) => j.update());
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