// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = 16'("ab");
  localparam Y = 8'(-W);
endpackage
module top import p::*; #(parameter Q = 1) (output logic [15:0] o);
  assign o = X + Y;
endmodule
