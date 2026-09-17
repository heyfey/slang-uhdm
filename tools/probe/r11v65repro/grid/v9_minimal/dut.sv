// v9 - ONE CELL PER MODULE.  Isolating why the same shape answered 36 in one
// module and 0 in another.
package pz; typedef logic [1:0] zv_t; endpackage

module m1 (output logic [1:0] o);          // packedarr-of-alias element, ALONE
  typedef logic [1:0] v; typedef v [1:0] w; typedef w a [2];
  a x; assign o = x[0][0];
endmodule
module m2 (output logic [1:0] o);          // + an extra alias declared BEFORE w
  typedef logic [1:0] v; typedef v v2; typedef v [1:0] w; typedef w a [2];
  a x; assign o = x[0][0] | v2'(0);
endmodule
module m3 (output logic [1:0] o);          // + a WILDCARD import of an unrelated pkg
  import pz::*;
  typedef logic [1:0] v; typedef v [1:0] w; typedef w a [2];
  a x; assign o = x[0][0];
endmodule
module m4 (output logic [1:0] o);          // double-alias element, ALONE
  typedef logic [1:0] v; typedef v v2; typedef v2 a [2];
  a x; assign o = x[0];
endmodule
module m5 (output logic [1:0] o);          // single-alias element, ALONE (control)
  typedef logic [1:0] v; typedef v a [2];
  a x; assign o = x[0];
endmodule
module m6 (output logic [1:0] o);          // double alias + declarator dim, ALONE
  typedef logic [1:0] v; typedef v v2;
  v2 x [2]; assign o = x[0];
endmodule
module m7 (output logic [1:0] o);          // m1 shape with the NET declared FIRST
  typedef logic [1:0] v; typedef v [1:0] w; typedef w a [2];
  logic [1:0] pre; a x; assign pre = 2'b0; assign o = x[0][0] | pre;
endmodule
module m8 (output logic [1:0] o);          // m4 shape + an unrelated later typedef
  typedef logic [1:0] v; typedef v v2; typedef v2 a [2]; typedef logic [1:0] tail;
  a x; tail t; assign o = x[0] | t;
endmodule
module dut (output logic [1:0] o);
  logic [1:0] a1,a2,a3,a4,a5,a6,a7,a8;
  m1 u1(.o(a1)); m2 u2(.o(a2)); m3 u3(.o(a3)); m4 u4(.o(a4));
  m5 u5(.o(a5)); m6 u6(.o(a6)); m7 u7(.o(a7)); m8 u8(.o(a8));
  assign o = a1|a2|a3|a4|a5|a6|a7|a8;
endmodule
