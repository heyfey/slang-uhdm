// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  parameter logic [23:0] X = (W+V)'('h0010_0000);
  parameter logic [23:0] Y = 24'('h0010_0000);
endpackage
module top import p::*; #(parameter Q = 1) ();
endmodule
