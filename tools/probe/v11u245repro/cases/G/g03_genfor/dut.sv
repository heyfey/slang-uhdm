// § unitLawSGenVarIsInstVar245v
// a $unit vector typedef variable in each iteration of a generate loop
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o0, o1);
  for (genvar k = 0; k < 2; k++) begin : g
    nib_t v;
  end
  assign g[0].v = i;
  assign g[1].v = ~i;
  assign o0 = g[0].v;
  assign o1 = g[1].v;
endmodule
