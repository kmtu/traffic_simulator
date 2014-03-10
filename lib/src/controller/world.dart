part of traffic_simulator;

class World implements Controller {
  WorldModel model = new WorldModel();
  WorldView view;

  final Queue<Vehicle> garage = new Queue<Vehicle>();

  GameLoopHtml gameLoop;
  double pixelPerMeter = 10.0;
  double dtRender = 0.0;
  double dtUpdate;
  bool pause;

  get road => model.road;
  get joint => model.joint;

  World(this.gameLoop, {Random random, double pixelPerMeter: 10.0}) {
    if (random == null) {
      random = new Random(new DateTime.now().millisecondsSinceEpoch);
    }
    dtUpdate = gameLoop.dt;
  }

  Random get random => model.random;
  void render() => view.render();

  void addRoad(Iterable<Road> road) {
    for (Road rd in road) {
      rd.world = this;
      rd.addView(new RoadView(view.canvas, rd));
      model.road.add(rd);
      for (RoadEnd re in rd.roadEnd) {
        if (re.joint != null) {
          re.joint.world = this;
          re.joint.view = new JointView(view.canvas, re.joint);
          model.joint.add(re.joint);
        }
      }
    }
  }

  Vehicle requestVehicle() {
    if (garage.isEmpty) {
      return new Vehicle(this);
    }
    else {
      return garage.removeLast();
    }
  }

  void update() {
    model.road.forEach((r) => r.update());
    model.joint.forEach((j) => j.update());
  }
}
