// § parenCastReadsCastSyntax288 — several parenthesis levels, a cast of a parenthesized operand and a cast of a parenthesized cast in a process
module top(input logic [7:0] x, output int o, o2, o3);
  always_comb begin
    o = (((int'(x)))) + 1;
    o2 = int'((x)) + 1;
    o3 = int'((byte'(x))) + (int'((x)));
  end
endmodule
