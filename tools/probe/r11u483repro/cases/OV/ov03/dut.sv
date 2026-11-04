// § clsScopedOvRhsRefObj483
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub #(A = 8, B = 4) ();
  logic [A-1:0] d;
  logic [B-1:0] e;
endmodule
module top;
  import p::*;
  sub #(.A(S::w), .B(3)) u();
  sub v();
endmodule
