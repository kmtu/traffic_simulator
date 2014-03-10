part of traffic_simulator;

class JointModel implements Model {
  Set<RoadEnd> roadEnd = new Set<RoadEnd>();
  Set<RoadEnd> inwardRoadEnd =  new Set<RoadEnd>();
  Set<RoadEnd> outwardRoadEnd =  new Set<RoadEnd>();
  String label = "";
  Color labelCircleColor;
}
