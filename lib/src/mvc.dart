part of traffic_simulator;

abstract class Controller {
  Model model;
  View view;
}

abstract class View<Controller> {
  Controller controller;
  CanvasElement canvas;

  Matrix3 transformMatrix = new Matrix3.identity();

  View(this.canvas, this.controller);

  void update();
  void render();
}

abstract class Model {

}