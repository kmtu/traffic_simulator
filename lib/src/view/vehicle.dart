part of traffic_simulator;

class VehicleView extends View<VehicleController> {
  VehicleView(CanvasElement canvas, VehicleController vehicle) : super(canvas, vehicle);

  @override
  void update() {
    // TODO: implement update
  }

  @override
  void render() {
    // the lane center is x-aixs, lane begins from origin to the positive x
    CanvasRenderingContext2D context = canvas.context2D;
    context.save();

    transformContext(context, preTranslate(transformMatrix, controller.pos + controller.vel * world.dtRender, 0.0));
    // draw as if the reference point of the vehicle is the origin

    context.setFillColorRgb(color.r, color.g, color.b);
    context.fillRect(-length, -width / 2, length, width);
    context.restore();
  }
}