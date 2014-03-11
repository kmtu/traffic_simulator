part of traffic_simulator;

class Lane implements Model {
  DoubleLinkedQueue<VehicleController> vehicle = new DoubleLinkedQueue<VehicleController>();
  Road road;
  final double width;
  /// Direction of this lane, can be [Road.FORWARD] or [Road.BACKWARD]
  final int direction;

  /// The direction of a lane is always from laneEnd[0] to laneEnd[1]
  List<RoadEndController> laneEnd;
  DoubleLinkedQueueEntry<LaneController> entry;
  final Queue<VehicleController> queue = new Queue<VehicleController>();

  Lane(this.road, this.direction, this.width);
}