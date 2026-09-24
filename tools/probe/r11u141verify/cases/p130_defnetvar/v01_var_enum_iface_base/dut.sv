// § defNetVarNoSlot130v
// case v01: var with an anonymous enum without a base, in a generate block
module top(output int o);
  if (1) begin : g
    var enum {P, Q, R} y;
  end
  assign o = g.y;
endmodule
