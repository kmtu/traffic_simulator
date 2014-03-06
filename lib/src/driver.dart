part of traffic_simulator;


class Driver {
  final Vehicle vehicle;
  TrafficSimulator world;
  double safeDistance;
  Lane nextLane;
  Driver(this.world, {this.vehicle});
  
  void update() {
    if (nextLane == null) {
      nextLane = vehicle.lane.laneEnd.last.joint.getRandomOutwardLane();
    }
    
    DoubleLinkedQueueEntry<Vehicle> nextVehicleEntry = vehicle.entry.nextEntry();
    Vehicle nextVehicle;
    double distance;
    if (nextVehicleEntry != null) {
      nextVehicle = nextVehicleEntry.element;
      distance = nextVehicle.pos - nextVehicle.length - vehicle.pos;
    }
    else {
      if (nextLane.vehicle.isNotEmpty) {
        nextVehicle = nextLane.vehicle.first;
        distance = nextVehicle.pos - nextVehicle.length +
            vehicle.lane.road.length - vehicle.pos;
      }
    }
    
    if (nextVehicle != null) {
      safeDistance = vehicle.vel * vehicle.vel / (2 * vehicle.accMax);
      if (distance < safeDistance && vehicle.vel > 0) {
        vehicle.acc = -vehicle.accMax;
      }
      else if (distance > safeDistance) {
        vehicle.acc = vehicle.accMax;
      }
      else 
      {
        vehicle.acc = 0.0;
      }
    }
    else {
      vehicle.acc = vehicle.accMax;
    }
      
    if (vehicle.pos - vehicle.length > vehicle.lane.road.length) {
      if (vehicle.lane.removeLastVehicle() != this.vehicle) {
        throw new StateError("The last removed vehicle must be the one who " 
                             "goes over the road end first.");
      }
      nextLane.addFirstVehicle(vehicle);
    }
  }
}