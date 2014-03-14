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
part 'src/lane.dart';
part 'src/lane.view.dart';
part 'src/vehicle.dart';
part 'src/vehicle.view.dart';
part 'src/joint.dart';
part 'src/joint.view.dart';
part 'src/utility.dart';
part 'src/camera.dart';
part 'src/data_structure.dart';
part 'src/controller.dart';

abstract class View<E> {
  E model;
  View(this.model);

  void draw(Camera camera);
  void update();

}
