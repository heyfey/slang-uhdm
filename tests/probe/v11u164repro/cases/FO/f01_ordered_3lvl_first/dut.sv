// § firstOrderedPathSel161 — an ordered list whose first actual is a three-component path into a generate block
module ch(input a, input b, output c);
  assign c = a & b;
endmodule
module top(output o);
  if (1) begin : g
    if (1) begin : h
      wire x = 1'b1;
    end
    wire y = 1'b0;
  end
  ch u(g.h.x, g.y, o);
endmodule
