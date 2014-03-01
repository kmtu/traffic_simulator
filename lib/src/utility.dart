part of traffic_simulator;

Matrix3 translateMatrix3(Matrix3 M, double dx, double dy) {
  M.setColumn(2, new Vector3(M.entry(0, 2) + dx, M.entry(1, 2)+ dy, 1.0));
  return M;
}

Matrix3 makeTranslateMatrix3(double dx, double dy) {
  Matrix3 TM = new Matrix3.identity() ..setColumn(2, new Vector3(dx, dy, 1.0));
  return TM;
}