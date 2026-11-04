// § parenCastReadsCastSyntax288 — a parenthesized cast as a case condition and as case items
module top(input logic [7:0] x, output logic [1:0] o);
  always_comb
    case ((int'(x)))
      (int'(3)): o = 1;
      (byte'(4)), (byte'(5)): o = 2;
      default: o = 0;
    endcase
endmodule
