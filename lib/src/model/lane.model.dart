part of traffic_simulator;

class LaneModel implements Model {
  DoubleLinkedQueue<Vehicle> vehicle = new DoubleLinkedQueue<Vehicle>();
  Road road;
  final double width;
  /// Direction of this lane, can be [Road.FORWARD] or [Road.BACKWARD]
  final int direction;

  /// The direction of a lane is always from laneEnd[0] to laneEnd[1]
  List<RoadEnd> laneEnd;
  DoubleLinkedQueueEntry<Lane> entry;
  final Queue<Vehicle> queue = new Queue<Vehicle>();

  LaneModel(this.road, this.direction, this.width);
}