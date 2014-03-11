part of traffic_simulator;

abstract class Controller<Model> {
  Model model;
  List<View<Model>> view;
  Controller({this.model, this.view});
}

abstract class View<Model> {
  Controller<Model> controller;
  CanvasElement canvas;

  Matrix3 transformMatrix = new Matrix3.identity();

  View(this.canvas, this.controller);

  void update();
  void render();
}

abstract class Model {
  Controller controller;
}