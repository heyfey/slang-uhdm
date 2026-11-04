// § firstOrderedPathSel161 — an ordered list whose first actual is a selected path (the law abstains)
module ch(input a, input b, output c);
  assign c = a & b;
endmodule
module top(output o);
  if (1) begin : g
    wire [1:0] x = 2'b10;
    wire y = 1'b0;
  end
  ch u(g.x[1], g.y, o);
endmodule
