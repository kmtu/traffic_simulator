part of traffic_simulator;

/**
 * Returns a new translation matrix with [dx], [dy]
 */
Matrix3 makeTranslateMatrix3(double dx, double dy) {
  Matrix3 tm = new Matrix3.identity() ..setColumn(2, new Vector3(dx, dy, 1.0));
  return tm;
}

Matrix3 makeScaleMatrix3(double scale) {
  Matrix3 sm = new Matrix3.identity() ..setDiagonal(new Vector3(scale, scale, 1.0));
  return sm;
}

/**
 * Returns a new pre-translated [M] by [dx] and [dy]
 * [M] * [translate] * <old vector> = <new vector>
 */
Matrix3 preTranslate(Matrix3 M, double dx, double dy) {
  return M * makeTranslateMatrix3(dx, dy);
}

/**
 * [translate] * [M] * <old vector> = <new vector>
 */
Matrix3 postTranslate(Matrix3 M, double dx, double dy) {
  Matrix3 tm = M.clone() ..setColumn(2, new Vector3(M.entry(0, 2) + dx, M.entry(1, 2)+ dy, 1.0));
  return tm;
}

/**
 * Returns a transformation matrix which flips x coordinates
 *
 * That is, x becomes -x
 */
Matrix3 makeInvertXMatrix3() {
  return new Matrix3.identity().setDiagonal(new Vector3(-1.0, 1.0, 1.0));
}

void transformContext(CanvasRenderingContext2D context, Matrix3 M) {
  context.transform(M.entry(0, 0), M.entry(1, 0),
                    M.entry(0, 1), M.entry(1, 1),
                    M.entry(0, 2), M.entry(1, 2));
}

/*void translateMatrix(Matrix3 M, double dx, double dy) {
  M.setColumn(2, new Vector3(dx, dy, 1.0));
}*/

void forEachEntryFromLast(DoubleLinkedQueue dlq, f(DoubleLinkedQueueEntry element)) {
  DoubleLinkedQueueEntry entry = dlq.lastEntry();
  while (entry != null) {
    DoubleLinkedQueueEntry previousEntry = entry.previousEntry();
    f(entry);
    entry = previousEntry;
  }
}