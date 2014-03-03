part of traffic_simulator;

Matrix3 makeTranslateMatrix3(double dx, double dy) {
  Matrix3 tm = new Matrix3.identity() ..setColumn(2, new Vector3(dx, dy, 1.0));
  return tm;
}

Matrix3 preTranslate(Matrix3 M, double dx, double dy) {
  // [M] * [translate] * <old vector> = <new vector> 
  return M * makeTranslateMatrix3(dx, dy);
}

Matrix3 postTranslate(Matrix3 M, double dx, double dy) {
  // [translate] * [M] * <old vector> = <new vector> 
  Matrix3 tm = M.clone() ..setColumn(2, new Vector3(M.entry(0, 2) + dx, M.entry(1, 2)+ dy, 1.0));
  return tm;
}

/**
 * Returns a tranfomration matrix which flips x coordinates
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

/**
 * A reversible [DoubleLinkedQueue]
 * 
 * Implements some methods utilizes the reversibility nature of [DoubleLinkedQueue]
 */
class ReversibleDoubleLinkedQueue<E> extends DoubleLinkedQueue<E> {
  @override
  /**
   * This method is similar to the [lastWhere] method inherited from [Iterable],
   * but it iterates from the last entry instead of the first entry.
   */
  dynamic reversedLastWhere(bool test(E value), { Object orElse() }) {
    E result = null;
    bool foundMatching = false;
    DoubleLinkedQueueEntry<E> entry = lastEntry();
    while (entry != null) {
      if (test(entry.element)) return entry.element;
      entry = entry.previousEntry();
    }
    if (orElse != null) return orElse();
    throw new StateError("No matching element");
  }
}