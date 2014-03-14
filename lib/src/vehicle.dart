part of traffic_simulator;

class Vehicle implements Backtraceable {
  View view;
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
  World world;
  Color color;

  Vehicle(this.world, {this.width: 1.6, this.length: 3.5, this.accMax,
                       this.velMax, this.color, this.driver, this.view}) {
    if (driver == null) {
      this.driver = new Driver(world, vehicle: this);
    }

    if (color == null) {
      do {
        color = new Color(world.random.nextInt(2)*255, world.random.nextInt(2)*255,
          world.random.nextInt(2)*255);
      } while (color.r == 0 && color.g == 0 && color.b == 0);
    }

    if (accMax == null) {
      accMax = world.random.nextDouble() * 10 + 5;
    }

    if (velMax == null) {
      velMax = world.random.nextDouble() * 20 + 10;
    }

    if (view == null) {
      view = new VehicleView(this);
    }
  }

  void update() {
    double dt = world.dtUpdate;
    vel += acc*dt;
    if (vel > velMax) {
      vel = velMax;
    }
    if (vel != 0) {
      pos += vel*dt;
      view.update();
    }
    driver.update();
  }
}
