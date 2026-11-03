// § elabParamClsScopedSubst474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub #(A = 8) (output logic [A-1:0] o);
  wire [A:0] n;
  assign o = '0;
endmodule
module top;
  import p::*;
  wire [15:0] x;
  sub #(.A(S::w)) u(.o(x));
endmodule
