// § clsScopedRangeKept474 (attack: driven nets, downstream)
package p; class S; localparam w = 4; endclass endpackage
module top(input logic [3:0] i, output logic [3:0] o); import p::*;
  wire [S::w-1:0] a;
  assign a = i;
  assign o = a + 1;
endmodule
