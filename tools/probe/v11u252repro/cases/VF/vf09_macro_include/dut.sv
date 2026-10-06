// § impSizeCastFoldLocated252
`include "inc.svh"
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = `CASTW(8, W + V);
endpackage
module top import p::*; #(parameter Q = 1) (output logic [7:0] o);
  assign o = X;
endmodule
