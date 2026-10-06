// § impSizeCastFoldLocated252
package p;
  localparam W = 4;
  localparam V = 20;
  localparam X = 8'(W + 2);
endpackage
module top import p::*; #(parameter Q = 1) (input logic [X-1:0] i, output logic [X-1:0] o, output logic [7:0] r);
  logic [7:0] m [0:X-1];
  assign o = i[X-1:0];
  assign r = {X{1'b1}} | i[0 +: X];
endmodule
