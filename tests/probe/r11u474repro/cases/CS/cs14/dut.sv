// § clsScopedRangeKept474 (decode grid: a port typed by a class-scoped bound)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
import p::*;
module top (input logic [S::w-1:0] i, output wire [S::w-1:0] o);
  assign o = i;
endmodule
