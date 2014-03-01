part of traffic_simulator;


class Driver {
  static const double DEF_SIGHT_RANGE = 100.0; // meter
  static const double DEF_REACTION_TIME = 0.3; // sec
  double sightRange;
  double reactionTime;
  Vehicle vehicle;
  
  Driver({this.sightRange: DEF_SIGHT_RANGE, this.reactionTime: DEF_REACTION_TIME, this.vehicle});
}