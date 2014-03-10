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

void forEachEntryFromLast(DoubleLinkedQueue dlq, void f(DoubleLinkedQueueEntry element)) {
  DoubleLinkedQueueEntry entry = dlq.lastEntry();
  while (entry != null) {
    DoubleLinkedQueueEntry previousEntry = entry.previousEntry();
    f(entry);
    entry = previousEntry;
  }
}


class Color {
  int r, g, b;
  num a = 1;
  static Random _rand = new Random();

  Color(this.r, this.g, this.b, [this.a]);

  Color.red() {
    r = 255;
    g = 0;
    b = 0;
  }

  Color.black() {
    r = 0;
    g = 0;
    b = 0;
  }

  /**
   * [min] and [max] should be integers 0-255
   * [max] should be greater than [min]
   *
   * No check is performed for efficiency
   */
  Color.random({int min: 0, int max: 255}) {
    r = _rand.nextInt(max-min+1) + min;
    g = _rand.nextInt(max-min+1) + min;
    b = _rand.nextInt(max-min+1) + min;
  }

  Color clone() {
    return new Color(r, g, b, a);
  }

  @override
  bool operator ==(Color other) {
    if (r == other.r && g == other.g && b == other.b && a == other.a) {
      return true;
    }
    else {
      return false;
    }
  }

  @override
  int get hashCode {
    return (a+1) * 10000000 + (r+1) * 1000000 + (g+1) * 1000 + b;
  }
}
