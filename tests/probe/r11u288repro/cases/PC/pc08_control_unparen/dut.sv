// § parenCastReadsCastSyntax288 — CONTROL: the same casts with no parentheses, and parentheses around non-casts
module top(input logic [7:0] x, output logic [31:0] y, z, w);
  assign y = int'(x) + 1;
  assign z = (x + 1) + (x);
  always_comb w = byte'(x) ? (x) : (int'(x) + 1);
endmodule
