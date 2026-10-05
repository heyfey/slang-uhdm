// § unitLawSGenVarIsInstVar245v
// a $unit vector typedef variable in a generate block, assigned from outside the block
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    nib_t v;
  end
  assign g.v = i;
  assign o = g.v;
endmodule
