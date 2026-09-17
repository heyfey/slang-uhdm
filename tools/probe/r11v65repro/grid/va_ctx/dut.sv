// va - IS THE GOLDEN ANSWER CONTEXT-DEPENDENT?  m1's shape answered 0 alone and
// 36 in v2, where the INTERMEDIATE alias was ALSO declared as a net's own type.
module m9 (output logic [1:0] o);   // m1 + the intermediate alias used BEFORE
  typedef logic [1:0] v; typedef v [1:0] w; typedef w a [2];
  w wd; a x; assign o = wd[0] | x[0][0];
endmodule
module m10 (output logic [1:0] o);  // m1 + the intermediate alias used AFTER
  typedef logic [1:0] v; typedef v [1:0] w; typedef w a [2];
  a x; w wd; assign o = wd[0] | x[0][0];
endmodule
module m11 (output logic [1:0] o);  // m4 + the intermediate alias used
  typedef logic [1:0] v; typedef v v2; typedef v2 a [2];
  v2 vd; a x; assign o = vd | x[0];
endmodule
module m12 (output logic [1:0] o);  // m1 + the intermediate alias used with a dim
  typedef logic [1:0] v; typedef v [1:0] w; typedef w a [2];
  w wd [2]; a x; assign o = wd[0][0] | x[0][0];
endmodule
module m13 (output logic [1:0] o);  // m4 shape, intermediate used with a dim
  typedef logic [1:0] v; typedef v v2; typedef v2 a [2];
  v2 vd [2]; a x; assign o = vd[0] | x[0];
endmodule
module dut (output logic [1:0] o);
  logic [1:0] b9,b10,b11,b12,b13;
  m9 u9(.o(b9)); m10 u10(.o(b10)); m11 u11(.o(b11)); m12 u12(.o(b12)); m13 u13(.o(b13));
  assign o = b9|b10|b11|b12|b13;
endmodule
