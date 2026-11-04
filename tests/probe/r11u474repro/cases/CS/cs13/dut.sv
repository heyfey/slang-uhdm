// § elabParamClsScopedSubst474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub #(int A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  import p::*;
  sub #(.A(S::w)) u();
endmodule
