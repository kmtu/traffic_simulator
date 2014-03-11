part of traffic_simulator;

class WorldView extends View<World> {
  WorldView(CanvasElement canvas, Controller controller) :
      super(canvas, controller);

  final Set<RoadView> road = new Set<RoadView>();
  final Set<VehicleView> vehicle = new Set<VehicleView>();
  final Set<JointView> joint = new Set<JointView>();

  Vector2 pos;
  Vector2 dimension;
  double dt;

  @override
  void render() {
    if (controller.pause == false) {
      dt = controller.dtUpdate * controller.gameLoop.renderInterpolationFactor;
    }

    for (var rd in road) {
      rd.render();
    }

    for (var joint in joint) {
      joint.render();
    }
  }

  @override
  void update() {
    // TODO: implement update
  }

  void setWorld(World world) {
    road.clear();
    joint.clear();
    vehicle.clear();
    world.road.forEach((r) => this.addRoad(r));
    world.joint.forEach((j) => this.addJoint(j));
 }

  void addRoad(Road road) {
    this.road.add(new RoadView(canvas, road));
  }

  void addJoint(JointController joint) {
    this.joint.add(new JointView(canvas, joint));
  }

  void addVehicle(VehicleController vehicle) {
    this.vehicle.add(new VehicleView(canvas, vehicle));
  }
}