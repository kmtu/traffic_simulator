part of traffic_simulator;

class RoadEndModel implements Model {
  Vector2 pos;
  /// The road which this roadEnd connects to.
  final Road road;
  /// The index for roadEnd side (can be [Road.BEGIN] or [Road.END]).
  final int side;
  /// Outward means go onto the road,
  /// in order to be consistent with Joint's point of view.
  final DoubleLinkedQueue<Lane> outwardLane;
  /// Inward means leave the road,
  /// in order to be consistent with Joint's point of view.
  final DoubleLinkedQueue<Lane> inwardLane;

  Joint joint;

  RoadEndModel(this.road, this.side, this.pos,
      this.outwardLane, this.inwardLane);
}