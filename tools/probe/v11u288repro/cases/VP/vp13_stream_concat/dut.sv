// § parenCastReadsCastSyntax288 — parenthesized casts as concatenation members, streaming operands and a ternary condition
module top(input logic [7:0] x, y, output logic [15:0] o, o2, output int o3);
  assign o = {(byte'(x)), (byte'(y))};
  assign o2 = {<< 8 {(byte'(x)), (byte'(y))}};
  assign o3 = (int'(x)) ? (int'(y)) : (shortint'(x));
endmodule
