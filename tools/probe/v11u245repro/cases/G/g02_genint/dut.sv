// § unitLawSGenVarIsInstVar245v
// a $unit int typedef variable in a generate block, assigned from outside the block
typedef int ui_t;
module top(input int i, output int o);
  if (1) begin : g
    ui_t v;
  end
  assign g.v = i;
  assign o = g.v;
endmodule
