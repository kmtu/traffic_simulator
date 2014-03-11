part of traffic_simulator;

class RoadEnd implements Model {
  Vector2 pos;
  /// The road which this roadEnd connects to.
  final Road road;
  /// The index for roadEnd side (can be [Road.BEGIN] or [Road.END]).
  final int side;
  /// Outward means go onto the road,
  /// in order to be consistent with Joint's point of view.
  final DoubleLinkedQueue<LaneController> outwardLane;
  /// Inward means leave the road,
  /// in order to be consistent with Joint's point of view.
  final DoubleLinkedQueue<LaneController> inwardLane;

  JointController joint;

  RoadEnd(this.road, this.side, this.pos,
      this.outwardLane, this.inwardLane);

  @override
  void set controller(Controller _controller) {
    // TODO: implement controller
  }

  // TODO: implement controller
  @override
  Controller get controller => null;
}