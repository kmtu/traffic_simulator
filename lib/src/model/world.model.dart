part of traffic_simulator;

class WorldModel implements Model {
  final Set<Road> road = new Set<Road>();
  final Set<Vehicle> vehicle = new Set<Vehicle>();
  final Queue<Vehicle> garage = new Queue<Vehicle>();
  final Set<Joint> joint = new Set<Joint>();
  double dtRender = 0.0;
  double dtUpdate;
  Random random;
  bool pause = false;
}