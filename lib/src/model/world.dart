part of traffic_simulator;

class World implements Model {
  WorldController controller;
  final Set<Road> road = new Set<Road>();
  final Set<VehicleController> vehicle = new Set<VehicleController>();
  final Queue<VehicleController> garage = new Queue<VehicleController>();
  final Set<JointController> joint = new Set<JointController>();
  double dtRender = 0.0;
  double dtUpdate;
  Random random;
  bool pause = false;

  void addRoad(Iterable<Road> road) {
    for (Road rd in road) {
      rd.world = this;
      this.road.add(rd);
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
}