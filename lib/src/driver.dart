part of traffic_simulator;


class Driver {
  final Vehicle vehicle;
  TrafficSimulator world;
  double safeDistance;
  Lane nextAvailableLane;
  Driver(this.world, {this.vehicle});

  void update() {
    if (nextAvailableLane == null) {
      nextAvailableLane = vehicle.lane.laneEnd.last.joint.getRandomAvailableOutwardLane();
    }
    double distance;
    Vehicle nextVehicle;
    if (nextAvailableLane == null) {
      // unable to find nextLane, maybe a dead end or every lane is jammed
      distance = vehicle.lane.road.length - vehicle.pos;
    }
    else {
      DoubleLinkedQueueEntry<Vehicle> nextVehicleEntry = vehicle.entry.nextEntry();
      if (nextVehicleEntry != null) {
        nextVehicle = nextVehicleEntry.element;
        distance = nextVehicle.pos - nextVehicle.length - vehicle.pos;
      }
      else {
        // no vehicle ahead in this lane
        if (nextAvailableLane.vehicle.isNotEmpty) {
          nextVehicle = nextAvailableLane.vehicle.first;
          distance = nextVehicle.pos - nextVehicle.length +
              vehicle.lane.road.length - vehicle.pos;
        }
        else {
          distance = vehicle.lane.road.length + nextAvailableLane.road.length;
        }
      }

      if (vehicle.pos - vehicle.length > vehicle.lane.road.length) {
        if (vehicle.lane.removeLastVehicle() != this.vehicle) {
          throw new StateError("The last removed vehicle must be the one who "
                               "goes over the road end first.");
        }
        nextAvailableLane.addFirstVehicle(vehicle);
        nextAvailableLane = null;
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
  }
}