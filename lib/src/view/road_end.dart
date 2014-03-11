part of traffic_simulator;

class RoadEndView extends View<RoadEndController> {
  RoadEndView(CanvasElement canvas, Controller controller) :
      super(canvas, controller);


  @override
  void update() {
    // TODO: implement update
  }

  @override
  void render() {
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();
    transformContext(context, makeTranslateMatrix3(controller.pos.x, controller.pos.y));
    context.beginPath();
    context.arc(0, 0, controller.road.width / 2, 0, 2*PI);
    context.setFillColorRgb(controller.joint.labelCircleColor.r,
                            controller.joint.labelCircleColor.g,
                            controller.joint.labelCircleColor.b, 0.9);
    context.fill();
    context.textAlign = "center";
    context.textBaseline = "middle";
    context.setFillColorRgb(0, 0, 0);

    // Use larger font first then scale down to workaround the
    // minimum font size problem in Chrome
    context.save();
    context.scale(0.25, 0.25);
    context.font = "16px arial";
    context.fillText(controller.joint.label, 0, 0);
    context.restore();

    context.restore();
  }
}