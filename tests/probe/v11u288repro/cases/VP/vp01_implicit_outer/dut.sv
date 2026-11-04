// § parenCastReadsCastSyntax288 — a parenthesized cast under an implicit width conversion (narrower and wider targets, net declaration assignment)
module top(input logic [7:0] x, output logic [3:0] a, output logic [47:0] b, output logic [15:0] c);
  assign a = (int'(x));
  assign b = (byte'(x));
  wire [5:0] n = (shortint'(x));
  always_comb c = (int'(x));
endmodule
