part of traffic_simulator;

class VehicleModel implements Model {
  double pos = 0.0;
  double vel = 10.0;
  double acc = 0.0;
  double accMax;
  double velMax;
  Lane lane;
  Driver driver;
  double width;
  double length;
  DoubleLinkedQueueEntry entry;
  Color color;
}