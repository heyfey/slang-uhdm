// § clsScopedOvRhsRefObj483
package p;
  class C #(int N = 2);
    localparam w = N * 2;
  endclass
endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  import p::*;
  sub #(.A(C#(4)::w)) u();
endmodule
