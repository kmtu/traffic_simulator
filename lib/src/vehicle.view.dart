part of traffic_simulator;

class VehicleView implements View {
  Vehicle model;
  Matrix3 transformMatrix;

  VehicleView(this.model);

  @override
  void draw(Camera camera) {
    // the lane center is x-aixs, lane begins from origin to the positive x
    CanvasRenderingContext2D context = camera.buffer.context2D;
    context.save();

    transformContext(context, preTranslate(transformMatrix, model.vel * model.world.view.dt, 0.0));
    _paintVehicle(context);
    context.restore();
  }

  void _paintVehicle(CanvasRenderingContext2D context) {
    // draw as if the reference point of the vehicle is the origin
    context.setFillColorRgb(model.color.r, model.color.g, model.color.b);
    context.fillRect(-model.length, -model.width / 2, model.length, model.width);
  }

  @override
  void update() {
    if (model.lane != null) {
      // This vehicle is on a lane, so it can be drawn

      // Aligns the center of the lane to the x-axis
      transformMatrix = preTranslate(model.lane.view.transformMatrix, 0.0, model.lane.width / 2);
      if (model.lane.direction == Road.BACKWARD) {
        // It is a backward lane, swap the begin and end of the lane
        transformMatrix = transformMatrix * postTranslate(makeInvertXMatrix3(), model.lane.road.length, 0.0);
      }
      // Updates the vehicle pos
      transformMatrix = preTranslate(transformMatrix, model.pos, 0.0);
    }
  }
}