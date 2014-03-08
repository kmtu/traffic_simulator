part of traffic_simulator;


class Driver {
  final Vehicle vehicle;
  TrafficSimulator world;
  double safeDistance;
  double safeDistanceMin;
  Lane nextAvailableLane;
  Driver(this.world, {this.vehicle, this.safeDistanceMin}) {
    if (safeDistanceMin == null) {
      safeDistanceMin = world.random.nextDouble() * 2 + 0.5;
    }
  }

  void update() {
    safeDistance = vehicle.vel * vehicle.vel / (2 * vehicle.accMax) + safeDistanceMin;
    double distance;
    Vehicle nextVehicle;
    DoubleLinkedQueueEntry<Vehicle> nextVehicleEntry = vehicle.entry.nextEntry();
    if (nextVehicleEntry != null) {
      // This is not a leading vehicle
      nextVehicle = nextVehicleEntry.element;
      distance = nextVehicle.pos - nextVehicle.length - vehicle.pos;
    }
    else {
      // This is a leading vehicle
      double distanceToRoadEnd = vehicle.lane.road.length - vehicle.pos;
      if (distanceToRoadEnd < safeDistance) {
        // The road end is close, watch out!
        if (nextAvailableLane == null) {
          nextAvailableLane = vehicle.lane.laneEnd.last.joint.
              getRandomAvailableOutwardLane(vehicle: vehicle,
                  exceptRoadEnd: [vehicle.lane.laneEnd.last]);
        }

        if (nextAvailableLane == null) {
          // Unable to find an availabe lane, must prepare to stop before the road end
          distance = distanceToRoadEnd;
        }
        else {
          // Find an available lane
          nextAvailableLane.locked = true;
          if (nextAvailableLane.vehicle.isNotEmpty) {
            // There is vehicle on the next lane
            nextVehicle = nextAvailableLane.vehicle.first;
            distance = nextVehicle.pos - nextVehicle.length + distanceToRoadEnd;
          }
          else {
            // No vehicle ahead on the next lane!
            distance = distanceToRoadEnd + nextAvailableLane.road.length;
          }
        }
      }
      else {
        // The road end is still far away, just drive!!
        distance = distanceToRoadEnd;
      }
    }

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

    if (vehicle.pos - vehicle.length > vehicle.lane.road.length) {
      if (vehicle.lane.removeLastVehicle() != this.vehicle) {
        throw new StateError("The last removed vehicle must be the one who "
                             "goes over the road end first.");
      }
      if (nextAvailableLane == null) {
        throw new StateError("Don't break the traffic rule! "
            "There is no available lane but you still cross the road!");
      }
      else {
        nextAvailableLane.locked = false;
        nextAvailableLane.addFirstVehicle(vehicle);
        nextAvailableLane = null;
      }
    }
  }
}