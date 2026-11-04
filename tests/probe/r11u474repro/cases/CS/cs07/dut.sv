// § clsScopedRangeKept474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub;
  import p::*;
  wire [S::w-1:0] a;
endmodule
module top;
  sub u();
endmodule
