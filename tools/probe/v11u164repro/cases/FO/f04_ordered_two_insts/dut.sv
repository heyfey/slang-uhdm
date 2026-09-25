// § firstOrderedPathSel161 — two instances, each with a path first in an ordered list
module ch(input a, output c);
  assign c = a;
endmodule
module top(output o1, output o2);
  if (1) begin : g
    wire x = 1'b1;
  end
  ch u1(g.x, o1);
  ch u2(g.x, o2);
endmodule
