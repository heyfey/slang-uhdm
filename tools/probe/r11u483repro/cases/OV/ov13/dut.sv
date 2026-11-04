// § clsScopedOvRhsRefObj483
package p;
  class S;
    localparam w = 16;
  endclass
  class K;
    localparam v = 5;
  endclass
endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  import p::*;
  sub #(.A(S::w)) u();
  sub #(.A(K::v)) v();
endmodule
