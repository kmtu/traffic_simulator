part of traffic_simulator;

class Joint {
  View<Joint> view;
  Set<RoadEnd> roadEnd = new Set<RoadEnd>();
  Set<RoadEnd> _inwardRoadEnd = new Set<RoadEnd>();
  Set<RoadEnd> _outwardRoadEnd = new Set<RoadEnd>();
  String label;

  Joint({this.label: "", this.view}) {
    if (view == null) {
      view = new JointView(this);
    }
  }

  World world;

  void addRoadEnd(RoadEnd roadEnd) {
    this.roadEnd.add(roadEnd);
    updateOnRoadChange();
  }

  void removeRoadEnd(RoadEnd end) {
    roadEnd.remove(end);
    updateOnRoadChange();
  }

  void updateOnRoadChange() {
    _inwardRoadEnd.clear();
    _outwardRoadEnd.clear();
    for (var roadEnd in this.roadEnd) {
      if (roadEnd.outwardLane.length > 0) _outwardRoadEnd.add(roadEnd);
      if (roadEnd.inwardLane.length > 0) _inwardRoadEnd.add(roadEnd);
    }
  }


  Lane getRandomAvailableOutwardLane({Vehicle vehicle, List<RoadEnd>
      excludeRoadEnd, List<Lane> excludeLane}) {
    Iterable<RoadEnd> roadEnd = getAvailableOutwardRoadEnd(vehicle: vehicle,
        excludeRoadEnd: excludeRoadEnd);
    if (roadEnd.isNotEmpty) {
      Iterable lane = roadEnd.elementAt(world.random.nextInt(roadEnd.length)
          ).getAvailableOutwardLane(vehicle: vehicle, excludeLane: excludeLane);
      if (lane.isNotEmpty) {
        return lane.elementAt(world.random.nextInt(lane.length));
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Lane getRandomLeastQueueOutwardLane({Iterable<RoadEnd>
      excludeRoadEnd, Iterable<Lane> excludeLane}) {
    if (this._outwardRoadEnd.isNotEmpty) {
      Iterable roadEnd = _outwardRoadEnd;
      if (excludeRoadEnd != null) {
        roadEnd = roadEnd.where((r) => !excludeRoadEnd.contains(r));
      }
      Iterable lane = roadEnd.elementAt(world.random.nextInt(roadEnd.length)
          ).getLeastQueueOutwardLane(excludeLane: excludeLane);
      if (lane.isNotEmpty) {
        return lane.elementAt(world.random.nextInt(lane.length));
      } else {
        return null;
      }
    } else {
      return null;
    }
  }


  Iterable<RoadEnd> getAvailableOutwardRoadEnd({Vehicle vehicle, List<RoadEnd>
      excludeRoadEnd}) {
    if (excludeRoadEnd == null) {
      return _outwardRoadEnd.where((r) => r.hasAvailableOutwardLane(vehicle:
          vehicle));
    } else {
      return _outwardRoadEnd.where((r) => (!excludeRoadEnd.contains(r)) &&
          r.hasAvailableOutwardLane(vehicle: vehicle));
    }
  }

  Iterable<RoadEnd> getOutwardRoadEnd({List<RoadEnd> excludeRoadEnd}) {
    if (excludeRoadEnd == null) {
      return _outwardRoadEnd;
    } else {
      return _outwardRoadEnd.where((r) => !excludeRoadEnd.contains(r));
    }
  }

  void update() {
  }
}

class SourceJoint extends Joint {
  @override
  View<SourceJoint> view;

  bool spawning = false;
  Lane spawnLane;
  double spawnInterval = 1.0;
  double accumulatedTime = 0.0;
  int maxSpawn;

  SourceJoint({String label, this.maxSpawn: 10, this.view}): super(label: label,
      view: null) {
    view = new SourceJointView(this);
  }

  @override
  void update() {
    if (maxSpawn > 0) {
      if (accumulatedTime >= spawnInterval) {
        if (randomDispatch()) {
          // Successfully spawned
          accumulatedTime = 0.0;
          spawning = true;
          view.update();
          roadEnd.forEach((re) => re.view.update());
          spawning = false;
        } else {
          accumulatedTime += world.dtUpdate;
        }
      } else {
        accumulatedTime += world.dtUpdate;
      }
    }
  }

  bool randomDispatch() {
    var vehicle = world.requestVehicle();
    // Randomly pick a lane to add
    Lane lane = getRandomAvailableOutwardLane(vehicle: vehicle);
    if (lane != null) {
      spawnLane = lane;
      lane.addFirstVehicle(vehicle);
      maxSpawn--;
      return true;
    } else {
      return false;
    }
  }
}
