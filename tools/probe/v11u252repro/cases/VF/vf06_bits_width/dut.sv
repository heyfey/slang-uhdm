// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam logic [5:0] Z = 0;
  localparam X = $bits(Z)'(5);
  localparam Y = (W*2)'(V);
endpackage
module top import p::*; #(parameter Q = 1) (output logic [7:0] o);
  assign o = X + Y;
endmodule
