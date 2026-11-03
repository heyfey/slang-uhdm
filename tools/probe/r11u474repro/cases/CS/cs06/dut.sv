// § clsScopedRangeKept474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  import p::*;
  sub #(S::w) u();
  sub #(.A(S::w + 1)) v();
endmodule
