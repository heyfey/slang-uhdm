// § clsScopedRangeKept474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
  typedef logic [S::w-1:0] w_t;
endpackage
module top;
  import p::*;
  w_t a;
  parameter logic [S::w-1:0] P = 0;
endmodule
