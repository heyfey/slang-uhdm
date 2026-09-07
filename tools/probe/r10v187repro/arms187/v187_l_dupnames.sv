// v187 arm L -- the SAME typedef name in two packages, a CROSS-PACKAGE chained
// typedef, and a file with NO module at all (DEF-only listings).
package pl1187;
  typedef int  x_t;
  typedef byte y_t;
  parameter x_t L1_P = 1;
  parameter y_t L1_Q = 2;
endpackage
package pl2187;
  typedef int x_t;
  parameter x_t L2_P = 3;
  typedef pl1187::x_t z_t;
  parameter z_t L2_Z = 4;
  typedef x_t w_t;
  parameter w_t L2_W = 5;
endpackage
