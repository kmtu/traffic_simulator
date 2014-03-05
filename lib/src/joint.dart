part of traffic_simulator;

abstract class Joint {
  Set<RoadEnd> roadEnd = new Set<RoadEnd>();
  Set<RoadEnd> _inwardRoadEnd =  new Set<RoadEnd>();
  Set<RoadEnd> _outwardRoadEnd =  new Set<RoadEnd>();
  String label = ""; 
  
  Joint(String this.label);
  
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
    _inwardRoadEnd.clear();
    _outwardRoadEnd.clear();
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
      return roadEnd.road.forwardLane.length > 0;
    }
    else if (roadEnd.side == Road.END_SIDE) {
      return roadEnd.road.backwardLane.length > 0;
    }
    else {
      // road is not connected to this joint
      return false;
    }
  }
  
  bool isInward(RoadEnd roadEnd) {
    if (roadEnd.side == Road.BEGIN_SIDE) {
      return roadEnd.road.backwardLane.length > 0;
    }
    else if (roadEnd.side == Road.END_SIDE) {
      return roadEnd.road.forwardLane.length > 0;
    }
    else {
      // road is not connected to this joint
      return false;
    }
  }
  
  void draw(Camera camera);
  
  void drawLabel(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    for (var roadEnd in this.roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, 3, 0, 2*PI);
      context.setFillColorRgb(0, 200, 0);
      context.fill();
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.setFillColorRgb(0, 0, 0);
      context.font = "4px arial";
      context.fillText(label, 0, 0.4);
      context.restore();
    }
  }
  
  void update();
}

class SourceJoint extends Joint {
  double spawnInterval = 1.0;
  double accumulatedTime = 0.0;
  double _opacity;
  double opacityFreq = 0.5;
  double maxOpacity = 0.5;
  double minOpacity = 0.1;
  
  SourceJoint(String label) : super(label) {
    _opacity = maxOpacity;
  }
 
  @override
  void update() {
    if (accumulatedTime < spawnInterval) {
      accumulatedTime += world.gameLoop.dt;
    }
    else {
      accumulatedTime = 0.0;
      randomDispatch();
    }
    
    _updateBlink();
  }
  
  void _updateBlink() {
    _opacity += opacityFreq * world.gameLoop.dt;    
    if (_opacity > maxOpacity) {
      _opacity = maxOpacity;
      opacityFreq *= -1;      
    }
    else if (_opacity < minOpacity) {
      _opacity = minOpacity;
      opacityFreq *= -1;      
    }    
  }
  
  void randomDispatch() {
    // Randomly pick a roadEnd to add
    var roadEnd = _outwardRoadEnd.elementAt(world.random.nextInt(_outwardRoadEnd.length));
    roadEnd.requestAddVehicle(world.requestVehicle());
  }
  
  void draw(Camera camera) {
    CanvasRenderingContext2D context = camera.worldCanvas.context2D;
    for (var roadEnd in this.roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, roadEnd.road.width*0.5, 0, 2*PI);
      context.setFillColorRgb(200, 0, 0, _opacity);
      context.fill();
      context.restore();
    }
    drawLabel(camera);
  }
}