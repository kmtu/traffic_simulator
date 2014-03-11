part of traffic_simulator;

class JointView extends View<JointController> {
  JointView(CanvasElement canvas, Controller controller) :
      super(canvas, controller);


  @override
  void update() {
    // TODO: implement update
  }

  @override
  void render() {
    drawLabel();
  }

  void drawLabel() {
    CanvasRenderingContext2D context = canvas.context2D;
    for (var roadEnd in roadEnd) {
      context.save();
      transformContext(context, makeTranslateMatrix3(roadEnd.pos.x, roadEnd.pos.y));
      context.beginPath();
      context.arc(0, 0, roadEnd.road.width / 2, 0, 2*PI);
      context.setFillColorRgb(controller.labelCircleColor.r,
                              controller.labelCircleColor.g,
                              controller.labelCircleColor.b, 0.9);
      context.fill();
      context.textAlign = "center";
      context.textBaseline = "middle";
      context.setFillColorRgb(0, 0, 0);

      // Use larger font first then scale down to workaround the
      // minimum font size problem in Chrome
      context.save();
      context.scale(0.25, 0.25);
      context.font = "16px arial";
      context.fillText(controller.label, 0, 0);
      context.restore();

      context.restore();
    }
  }

}