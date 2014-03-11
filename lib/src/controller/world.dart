part of traffic_simulator;

class WorldController extends Controller {
  World _model;
  List<WorldView> view;

  final Set<RoadController> road = new Set<RoadController>();
  final Set<VehicleController> vehicle = new Set<VehicleController>();
  final Queue<VehicleController> garage = new Queue<VehicleController>();
  final Set<JointController> joint = new Set<JointController>();

  GameLoopHtml gameLoop;
  double pixelPerMeter = 10.0;
  double dtRender = 0.0;
  double dtUpdate;
  bool pause;

  get model => _model;
  set model(World world) {
    this._model = world;
    view.forEach((v) => v.setWorld(world));
  }

  WorldController(this.gameLoop, {Random random, double pixelPerMeter: 10.0}) {
    if (random == null) {
      random = new Random(new DateTime.now().millisecondsSinceEpoch);
    }
    dtUpdate = gameLoop.dt;
  }

  Random get random => _model.random;
  void render() => view.forEach((v) => v.render());

  void addRoad(Iterable<Road> road) {
    if (model == null) throw new StateError("A model must be set before this controller can work.");
    model.addRoad(road);
    view.forEach((v) => v.addRoad(road));
    road.forEach((r) => this.road.add(new RoadController(model: r, view: view)));

    for (Road rd in road) {
      for (RoadEndController re in rd.roadEnd) {
        if (re.joint != null) {
          re.joint.world = this;
          view.forEach((v) => v.addJoint(joint));
//          re.joint.view = new JointView(view.canvas, re.joint);
          model.joint.add(re.joint);
        }
      }
    }
  }

  VehicleController requestVehicle() {
    if (garage.isEmpty) {
      return new VehicleController(this);
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
