part of traffic_simulator;

/**
 * The interface of Road to Joint.
 */
class RoadEndController implements Controller {
  WorldController world;
  RoadEnd _model;
  RoadEndView view;

  RoadEndController(Road road, int side, Vector2 pos,
      DoubleLinkedQueue<LaneController> outwardLane, DoubleLinkedQueue<LaneController> inwardLane) {
    _model = new RoadEnd(road, side, pos, outwardLane, inwardLane);

  }

  Vector2 get pos => _model.pos;
  JointController get joint => _model.joint;
  DoubleLinkedQueue<LaneController> get outwardLane => _model.outwardLane;
  DoubleLinkedQueue<LaneController> get inwardLane => _model.inwardLane;
  Road get road => _model.road;

  void addJoint(JointController joint) {
    if (_model.joint != null) {
      _model.joint.removeRoadEnd(this);
    }
    _model.joint = joint;
    joint.addRoadEnd(this);
  }

  void updateOnLaneChange() {
    if (_model.joint != null) _model.joint.updateOnRoadChange();
  }

  LaneController getRandomOutwardLane() {
    var max = _model.outwardLane.length;
    if (max > 0) {
      return _model.outwardLane.elementAt(world.random.nextInt(max));
    }
    else {
      return null;
    }
  }

  Iterable<LaneController> getAvailableOutwardLane({VehicleController vehicle, List<LaneController> excludeLane}) {
    if (excludeLane == null) {
      return _model.outwardLane.where((l) => l.availableForAddVehicle(vehicle: vehicle));
   }
    else {
      return _model.outwardLane.where((l) => (!excludeLane.contains(l)) && l.availableForAddVehicle(vehicle: vehicle));
    }
  }

  bool hasAvailableOutwardLane({VehicleController vehicle}) {
    return _model.outwardLane.any((l) => l.availableForAddVehicle(vehicle: vehicle));
  }

  Iterable<LaneController> getLeastQueueOutwardLane({Iterable<LaneController> excludeLane}) {
    if (excludeLane == null) {
      int min = _model.outwardLane.fold(_model.outwardLane.first.queue.length, (v, l) =>
          l.queue.length <= v ? l.queue.length : v);
      return _model.outwardLane.where((l) => l.queue.length == min);
   }
    else {
      int min = _model.outwardLane.fold(_model.outwardLane.first.queue.length, (v, l) =>
          l.queue.length <= v ? l.queue.length : v);
      return _model.outwardLane.where((l) => (l.queue.length == min) &&
          (!excludeLane.contains(l)));
    }
  }
}
