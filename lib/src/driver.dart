part of traffic_simulator;


class Driver {
  final Vehicle vehicle;
  TrafficSimulator world;
  
  Driver(this.world, {this.vehicle});
  
  void update() {
/*    DoubleLinkedQueueEntry<Vehicle> nextVehicle = vehicle.entry.nextEntry();
    if (nextVehicle != null) {
      double distance = nextVehicle.element.pos - nextVehicle.element.length - vehicle.pos;
      if (distance < 5) {
        vehicle.acc = -5.0;
      }
      else if (distance > 10) {
        vehicle.acc = 1.0;
      }
      else 
      {
        vehicle.acc = 0.0;
      }
    }
*/    
    Road road = vehicle.lane.road;
    if (vehicle.pos - vehicle.length > road.length) {
      if (vehicle.lane.removeLastVehicle() != this.vehicle) {
        throw new StateError("The last removed vehicle must be the one who " 
                             "goes over the road end first.");
      }
      vehicle.lane.laneEnd.last.joint.getRandomOutwardLane().addFirstVehicle(vehicle);
    }
  }
}