// § unitTdLawS245
// a $unit vector typedef on a variable inside a generate block
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    nib_t v;
    assign v = i;
  end
  assign o = g.v;
endmodule
