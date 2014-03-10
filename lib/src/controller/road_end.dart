part of traffic_simulator;

/**
 * The interface of Road to Joint.
 */
class RoadEnd implements Controller {
  World world;
  RoadEndModel model;
  RoadEndView view;

  RoadEnd(Road road, int side, Vector2 pos,
      DoubleLinkedQueue<Lane> outwardLane, DoubleLinkedQueue<Lane> inwardLane) {
    model = new RoadEndModel(road, side, pos, outwardLane, inwardLane);

  }

  Vector2 get pos => model.pos;
  Joint get joint => model.joint;
  DoubleLinkedQueue<Lane> get outwardLane => model.outwardLane;
  DoubleLinkedQueue<Lane> get inwardLane => model.inwardLane;
  Road get road => model.road;

  void addJoint(Joint joint) {
    if (model.joint != null) {
      model.joint.removeRoadEnd(this);
    }
    model.joint = joint;
    joint.addRoadEnd(this);
  }

  void updateOnLaneChange() {
    if (model.joint != null) model.joint.updateOnRoadChange();
  }

  Lane getRandomOutwardLane() {
    var max = model.outwardLane.length;
    if (max > 0) {
      return model.outwardLane.elementAt(world.random.nextInt(max));
    }
    else {
      return null;
    }
  }

  Iterable<Lane> getAvailableOutwardLane({Vehicle vehicle, List<Lane> excludeLane}) {
    if (excludeLane == null) {
      return model.outwardLane.where((l) => l.availableForAddVehicle(vehicle: vehicle));
   }
    else {
      return model.outwardLane.where((l) => (!excludeLane.contains(l)) && l.availableForAddVehicle(vehicle: vehicle));
    }
  }

  bool hasAvailableOutwardLane({Vehicle vehicle}) {
    return model.outwardLane.any((l) => l.availableForAddVehicle(vehicle: vehicle));
  }

  Iterable<Lane> getLeastQueueOutwardLane({Iterable<Lane> excludeLane}) {
    if (excludeLane == null) {
      int min = model.outwardLane.fold(model.outwardLane.first.queue.length, (v, l) =>
          l.queue.length <= v ? l.queue.length : v);
      return model.outwardLane.where((l) => l.queue.length == min);
   }
    else {
      int min = model.outwardLane.fold(model.outwardLane.first.queue.length, (v, l) =>
          l.queue.length <= v ? l.queue.length : v);
      return model.outwardLane.where((l) => (l.queue.length == min) &&
          (!excludeLane.contains(l)));
    }
  }
}
