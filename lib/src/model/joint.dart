part of traffic_simulator;

class Joint implements Model {
  Set<RoadEndController> roadEnd = new Set<RoadEndController>();
  Set<RoadEndController> inwardRoadEnd =  new Set<RoadEndController>();
  Set<RoadEndController> outwardRoadEnd =  new Set<RoadEndController>();
  String label = "";
  Color labelCircleColor;
}
