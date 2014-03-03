part of traffic_simulator;

class Joint {
  Set<RoadEnd> roadEnd = new Set<RoadEnd>();
  Set<RoadEnd> _inwardRoadEnd =  new Set<RoadEnd>();
  Set<RoadEnd> _outwardRoadEnd =  new Set<RoadEnd>();
  double radius;
  Vector2 pos = new Vector2.zero();
  TrafficSimulator world;
    
  void addRoadEnd(RoadEnd roadEnd) {
    this.roadEnd.add(roadEnd);
    updateOnRoadChange();
  }
  
  void removeRoadEnd(RoadEnd end) {
    roadEnd.remove(end);
    updateOnRoadChange();
  }
  
  void updateOnRoadChange() {
    radius = 0.0;
    _inwardRoadEnd.clear();
    _outwardRoadEnd.clear();
    for (RoadEnd re in roadEnd) {
      double tmpR = re.road.width / 2;
      if (tmpR > radius) {
        radius = tmpR;
      }
    }
    for (RoadEnd re in roadEnd) {
      if (isOutward(re)) {
        _outwardRoadEnd.add(re);
      }
      if (isInward(re)) {
        _inwardRoadEnd.add(re);
      }
    }
  }
  
  bool isOutward(RoadEnd roadEnd) {    
    if (roadEnd.side == Road.BEGIN_SIDE) {
      return roadEnd.road.lane.any((l) => l.direction == Road.FORWARD);
    }
    else if (roadEnd.side == Road.END_SIDE) {
      return roadEnd.road.lane.any((l) => l.direction == Road.BACKWARD);
    }
    else {
      // road is not connected to this joint
      return false;
    }
  }
  
  bool isInward(RoadEnd roadEnd) {
    if (roadEnd.side == Road.BEGIN_SIDE) {
      return roadEnd.road.lane.any((l) => l.direction == Road.BACKWARD);
    }
    else if (roadEnd.side == Road.END_SIDE) {
      return roadEnd.road.lane.any((l) => l.direction == Road.FORWARD);
    }
    else {
      // road is not connected to this joint
      return false;
    }
  }
  
  void drawOrphan(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    transformContext(context, makeTranslateMatrix3(pos.x, pos.y));
    context.beginPath();
    context.arc(0, 0, radius, 0, 2*PI);
    context.fillStyle = "red";
    context.fill();
    context.restore();
  }
  
  void drawWithRoadEnd(Camera camera, RoadEnd roadEnd) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
    context.beginPath();
    context.arc(0, 0, radius, 0, 2*PI);
    context.fillStyle = "grey";
    context.fill();
    context.restore();
  }
  
  void update() {
  }
}

class SourceJoint extends Joint {
  double spawnInterval = 0.5;
  double accumulatedTime = 0.0;
  
  @override
  void update() {
    if (accumulatedTime < spawnInterval) {
      accumulatedTime += world.gameLoop.dt;
    }
    else {
      accumulatedTime = 0.0;
      randomDispatch();
    }
  }
  
  void randomDispatch() {
    // Randomly pick a roadEnd to add
    var roadEnd = _outwardRoadEnd.elementAt(world.random.nextInt(_outwardRoadEnd.length));
//    world.gameLoop.addTimer((timer) => roadEnd.requestAddVehicle(world.requestVehicle()), 1.0);
    roadEnd.requestAddVehicle(world.requestVehicle());
  }
  
  @override  
  void drawOrphan(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    for (var re in roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(re.pos.x, re.pos.y));
      context.beginPath();
      context.arc(0, 0, radius, 0, 2*PI);
      context.fillStyle = "red";
      context.fill();   
      context.restore();
    }
  }
  
  @override
  void drawWithRoadEnd(Camera camera, RoadEnd roadEnd) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    context.save();
    transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
    context.beginPath();
    context.arc(0, 0, radius, 0, 2*PI);
    context.fillStyle = "orange";
    context.fill();
    context.restore();
  }
}