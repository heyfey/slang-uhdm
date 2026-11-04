// § clsScopedOvRhsRefObj483
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub #(A = 8) (output int y);
  assign y = A;
endmodule
module top;
  import p::*;
  int y;
  sub #(.A(S::w)) u(.y(y));
endmodule
