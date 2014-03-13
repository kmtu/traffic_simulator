library traffic_simulator;

import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

part 'src/world.dart';
part 'src/world.view.dart';
part 'src/driver.dart';
part 'src/road.dart';
part 'src/road.view.dart';
part 'src/vehicle.dart';
part 'src/joint.dart';
part 'src/lane.dart';
part 'src/utility.dart';
part 'src/camera.dart';
part 'src/data_structure.dart';

/*abstract class View<E> {
  E model;
  final Matrix3 transformMatrix = new Matrix3.identity();

  /**
   * [dt] is for interpolation drawing
   */
  void draw(CanvasElement canvas, double dt);

  View(this.model);
}*/
