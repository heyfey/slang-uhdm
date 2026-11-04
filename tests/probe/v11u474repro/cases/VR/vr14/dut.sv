// § clsScopedRangeKept474 (attack: ANSI ports typed with a class-scoped bound)
package p; class S; localparam w = 8; endclass endpackage
import p::*;
module sub(input logic [S::w-1:0] i, output logic [S::w-1:0] o);
  assign o = i;
endmodule
module top; logic [7:0] a, b; sub u(.i(a), .o(b)); endmodule
