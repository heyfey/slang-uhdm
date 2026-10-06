// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = 10'(W * V);
endpackage
module sub #(parameter Q = 1) (output logic [9:0] o);
  import p::*;
  assign o = X + Q;
endmodule
module top(output logic [9:0] o1, o2);
  sub u1(o1);
  sub #(2) u2(o2);
endmodule
