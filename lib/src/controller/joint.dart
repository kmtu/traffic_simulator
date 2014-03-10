part of traffic_simulator;

class Joint implements Controller {
  World world;
  JointModel model = new JointModel();
  JointView view;

  Joint(String label) {
    model.label = label;
    model.labelCircleColor = new Color.random(min: 100);
  }

  Set<RoadEnd> get roadEnd => model.roadEnd;
  String get label => model.label;
  Color get labelCircleColor => model.labelCircleColor;

  void render() => view.render();
  void update() {}

  void addRoadEnd(RoadEnd roadEnd) {
    model.roadEnd.add(roadEnd);
    updateOnRoadChange();
  }

  void removeRoadEnd(RoadEnd end) {
    model.roadEnd.remove(end);
    updateOnRoadChange();
  }

  void updateOnRoadChange() {
    model.inwardRoadEnd.clear();
    model.outwardRoadEnd.clear();
    for (var roadEnd in model.roadEnd) {
      if (roadEnd.outwardLane.length > 0) model.outwardRoadEnd.add(roadEnd);
      if (roadEnd.inwardLane.length > 0) model.inwardRoadEnd.add(roadEnd);
    }
  }

  Lane getRandomAvailableOutwardLane({Vehicle vehicle, List<RoadEnd> excludeRoadEnd,
                                      List<Lane> excludeLane}) {
    Iterable<RoadEnd> roadEnd = getAvailableOutwardRoadEnd(vehicle: vehicle,
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

  Lane getRandomLeastQueueOutwardLane({Iterable<RoadEnd> excludeRoadEnd,
                                       Iterable<Lane> excludeLane}) {
    if (model.outwardRoadEnd.isNotEmpty) {
      Iterable roadEnd = model.outwardRoadEnd;
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

  Iterable<RoadEnd> getAvailableOutwardRoadEnd({Vehicle vehicle, List<RoadEnd> excludeRoadEnd}) {
    if (excludeRoadEnd == null) {
      return model.outwardRoadEnd.where((r) => r.hasAvailableOutwardLane(vehicle: vehicle));
    }
    else {
      return model.outwardRoadEnd.where((r) =>
          (!excludeRoadEnd.contains(r)) && r.hasAvailableOutwardLane(vehicle: vehicle));
    }
  }

  Iterable<RoadEnd> getOutwardRoadEnd({List<RoadEnd> excludeRoadEnd}) {
    if (excludeRoadEnd == null) {
      return model.outwardRoadEnd;
    }
    else {
      return model.outwardRoadEnd.where((r) => !excludeRoadEnd.contains(r));
    }
  }
}