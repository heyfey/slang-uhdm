// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = 12'(V * 3);
endpackage
module top import p::*; #(parameter Q = X, localparam R = X + 1) (output logic [15:0] o);
  localparam S = X * 2;
  assign o = R + S + Q;
endmodule
