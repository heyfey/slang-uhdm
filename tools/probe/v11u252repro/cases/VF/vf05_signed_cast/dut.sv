// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = signed'(W);
  localparam Y = unsigned'(V);
endpackage
module top import p::*; #(parameter Q = 1) (output logic [7:0] o);
  assign o = X + Y;
endmodule
