part of traffic_simulator;

class RoadModel implements Model{
  double boundaryLineWidth = 1.0;

  /// Length of this road in meters
  double length;

  double width;
  /// Right-Hand Traffic or Left-Hand Traffic.
  /// Can be [Road.RHT] or [Road.LHT].
  int drivingHand;

  /// Lanes which direction are [Road.FORWARD]
  /// First added will be drawn as inner lanes
  final DoubleLinkedQueue<Lane> forwardLane = new DoubleLinkedQueue<Lane>();

  /// Lanes which direction are [Road.BACKWARD]
  /// First added will be drawn as inner lanes
  final DoubleLinkedQueue<Lane> backwardLane = new DoubleLinkedQueue<Lane>();

  /// Position of the two [roadEnd] of this road
  final List<RoadEnd> roadEnd = new List<RoadEnd>(2);
}