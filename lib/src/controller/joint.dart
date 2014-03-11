part of traffic_simulator;

class JointController implements Controller {
  WorldController world;
  Joint _model = new Joint();
  JointView view;

  JointController(String label) {
    _model.label = label;
    _model.labelCircleColor = new Color.random(min: 100);
  }

  Set<RoadEndController> get roadEnd => _model.roadEnd;
  String get label => _model.label;
  Color get labelCircleColor => _model.labelCircleColor;

  void update() {}

  void addRoadEnd(RoadEndController roadEnd) {
    _model.roadEnd.add(roadEnd);
    updateOnRoadChange();
  }

  void removeRoadEnd(RoadEndController end) {
    _model.roadEnd.remove(end);
    updateOnRoadChange();
  }

  void updateOnRoadChange() {
    _model.inwardRoadEnd.clear();
    _model.outwardRoadEnd.clear();
    for (var roadEnd in _model.roadEnd) {
      if (roadEnd.outwardLane.length > 0) _model.outwardRoadEnd.add(roadEnd);
      if (roadEnd.inwardLane.length > 0) _model.inwardRoadEnd.add(roadEnd);
    }
  }

  LaneController getRandomAvailableOutwardLane({VehicleController vehicle, List<RoadEndController> excludeRoadEnd,
                                      List<LaneController> excludeLane}) {
    Iterable<RoadEndController> roadEnd = getAvailableOutwardRoadEnd(vehicle: vehicle,
        excludeRoadEnd: excludeRoadEnd);
    if (roadEnd.isNotEmpty) {
      Iterable lane = roadEnd.elementAt(world.random.nextInt(roadEnd.length)).
            getAvailableOutwardLane(vehicle: vehicle, excludeLane: excludeLane);
      if (lane.isNotEmpty) {
        return lane.elementAt(world.random.nextInt(lane.length));
      }
      else {
        return null;
      }
    }
    else {
      return null;
    }
  }

  LaneController getRandomLeastQueueOutwardLane({Iterable<RoadEndController> excludeRoadEnd,
                                       Iterable<LaneController> excludeLane}) {
    if (_model.outwardRoadEnd.isNotEmpty) {
      Iterable roadEnd = _model.outwardRoadEnd;
      if (excludeRoadEnd != null) {
        roadEnd = roadEnd.where((r) => !excludeRoadEnd.contains(r));
      }
      Iterable lane = roadEnd.elementAt(world.random.nextInt(roadEnd.length)).
            getLeastQueueOutwardLane(excludeLane: excludeLane);
      if (lane.isNotEmpty) {
        return lane.elementAt(world.random.nextInt(lane.length));
      }
      else {
        return null;
      }
    }
    else {
      return null;
    }
  }

  Iterable<RoadEndController> getAvailableOutwardRoadEnd({VehicleController vehicle, List<RoadEndController> excludeRoadEnd}) {
    if (excludeRoadEnd == null) {
      return _model.outwardRoadEnd.where((r) => r.hasAvailableOutwardLane(vehicle: vehicle));
    }
    else {
      return _model.outwardRoadEnd.where((r) =>
          (!excludeRoadEnd.contains(r)) && r.hasAvailableOutwardLane(vehicle: vehicle));
    }
  }

  Iterable<RoadEndController> getOutwardRoadEnd({List<RoadEndController> excludeRoadEnd}) {
    if (excludeRoadEnd == null) {
      return _model.outwardRoadEnd;
    }
    else {
      return _model.outwardRoadEnd.where((r) => !excludeRoadEnd.contains(r));
    }
  }
}