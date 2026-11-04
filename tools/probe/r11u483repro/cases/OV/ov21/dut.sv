// § clsScopedOvRhsRefObj483
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
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.A(S::w)) u();
  end
endmodule
