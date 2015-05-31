part of traffic_simulator;

class Visualizer {
  World world;
  CanvasElement canvas, buffer;
  Camera camera;

  Visualizer(this.world, {Vector2 center}) {
    // Creates a view
    canvas = querySelector("#game-element");
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    buffer = new CanvasElement();

    camera = new Camera(this,
        center: center, height: 300.0, maxWidthPixel: 0, maxHeightPixel: 0);
  }

  void draw(double dt) {
    var bufferContext = buffer.context2D;
    bufferContext.clearRect(0, 0, buffer.width, buffer.height);
    bufferContext.save();
    camera.zoom(dt);
    drawWorld(dt);
    bufferContext.restore();
    canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);
    canvas.context2D.drawImageScaled(buffer, 0, 0, canvas.width, canvas.height);
  }

  void drawWorld(double dt) {
    var dtWorld;
    if (world.pause) {
      dtWorld = 0.0;
    }
    else {
      dtWorld = dt;
    }

    for (Road road in world.road) {
      drawRoad(dtWorld, road);
    //  rd.view.draw(dtWorld);
    }

    for (Joint joint in world.joint) {
      drawJoint(dtWorld, joint);
    //  joint.view.draw(dtWorld);
    }
  }

  void drawRoad(double dt, Road road) {
    var context = buffer.context2D;
    var transformMatrix = _getRoadTransformMatrix(road);

    context.save();
    if (road.forwardLane.isEmpty && road.backwardLane.isEmpty) {
      //Draw a line if the road contains no lane
      context.save();
      transformContext(context, transformMatrix);
      // draw as if the center of the road aligns to the x-axis

      context.beginPath();
      context.moveTo(0, 0);
      context.lineTo(road.length, 0);
      context.setStrokeColorRgb(255, 0, 0, 0.5);
      context.lineWidth = 1;
      context.stroke();
      context.restore();

    } else {
      var _upperLane, _lowerLane;
      if (road.drivingSide == Road.RHT) {
        _upperLane = road.backwardLane;
        _lowerLane = road.forwardLane;

      } else {
        _upperLane = road.forwardLane;
        _lowerLane = road.backwardLane;
      }
      _upperLane.forEach((lane) => drawLane(lane));
      _lowerLane.forEach((lane) => lane.view.draw(camera));
      _drawBoundary(camera);
    }
    model.roadEnd.forEach((re) => re.view.draw(camera));
    context.restore();
  }

  void drawLane(Lane lane) {
    var context = buffer.context2D;
    context.save();

    // top of this lane is aligned to x-axis
    transformContext(context, transformMatrix);

    // draw ground color
    context.beginPath();
    context.fillStyle = "black";
    context.fillRect(0, 0, lane.road.length, lane.width);
    context.setStrokeColorRgb(0, 0, 0);
    context.lineWidth = 1 / camera.pixelPerMeter;
    context.strokeRect(0, 0, lane.road.length, lane.width);

    // lanes are ordered as inner-lane first
    if (lane.entry.nextEntry() == null) {
      if (lane.entry.previousEntry() == null) {
        if (lane.road._getOppositeLane(model).isEmpty) {
          // Single lane road
        } else {
          // Only single lane with this direction,
          // Next to its "inside" is an opposite-direction lane
          // Draw: insdie yellow line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
        }
      } else {
        // Outermost lane with another same-direction lane inside
        // Draw: inside white line
        //        _beginPathInsideLine(context);
        _beginPathInsideDash(context, 5.0, 5.0);
        _strokeWhiteLine(context);
      }
    } else {
      if (lane.entry.previousEntry() == null) {
        if (lane.road._getOppositeLane(model).isEmpty) {
          // Outermost lane next to another same-directional lane.
          // This is a one-way traffic road with multiple lanes
          //        _beginPathInsideLine(context);
          _beginPathInsideDash(context, 5.0, 5.0);
          _beginPathOutsideDash(context, 5.0, 5.0);
          _strokeWhiteLine(context);
        } else {
          // Middle road with its "inside" next to an opposite-direction lane
          // Draw: inside yello line, outside white line
          _beginPathInsideLine(context);
          _strokeSingleYellowLine(context);
          _beginPathOutsideDash(context, 5.0, 5.0);
          _strokeWhiteLine(context);
        }
      } else {
        // God bless it's just a simple middle lane!
        _beginPathInsideDash(context, 5.0, 5.0);
        _strokeWhiteLine(context);
        _beginPathOutsideDash(context, 5.0, 5.0);
        _strokeWhiteLine(context);
      }
    }

    context.restore();
  }

  Matrix3 _getRoadTransformMatrix(Road road) {
    // rotate first then translate
    // [trans matrix]*[rot matrix]*<old vector> = <new vector>
    // one needs to post-multiply this transformMatrix with a tranlsate Matrix, first
    // to align the object's rotation point with the origin before doing the rotation.
    Vector2 d = road.roadEnd[1].pos - road.roadEnd[0].pos;
    var angle = atan2(d.y, d.x);
    var transformMatrix = new Matrix3.rotationZ(angle);
    transformMatrix = postTranslate(transformMatrix, road.roadEnd[0].pos.x,
    road.roadEnd[0].pos.y);
    return transformMatrix;
  }

  List<Matrix3> _getUpperLaneTransformMatrix(DoubleLinkedQueue<Lane> lanes) {
    var cumWidth_ = 0.0;
    var halfTotalLaneWidth = lanes.firstEntry().element.road.width / 2;
    forEachEntryFromLast(lanes, (laneEntry) {
      laneEntry.element.view.transformMatrix = preTranslate(transformMatrix,
      0.0, -halfTotalLaneWidth + cumWidth_);
      cumWidth_ += laneEntry.element.width;
    });
  }

  Matrix3 _getLowerLaneTransformMatrix() {
    // _lowerLane
    var cumWidth_ = 0.0;
    forEachEntryFromLast(_lowerLane, (laneEntry) {
      cumWidth_ += laneEntry.element.width;
      laneEntry.element.view.transformMatrix = preTranslate(transformMatrix,
      0.0, halfTotalLaneWidth - cumWidth_);
    });
  }

  void drawJoint(double dt, Joint joint) {
  }


  void update(double dt) {
    camera.update(dt);
  }

  void resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    camera.resize();
  }
}
