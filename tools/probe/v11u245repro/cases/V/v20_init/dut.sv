// § unitTdLawS245
// a $unit vector typedef on a variable with an initializer and an always_ff
typedef logic [3:0] nib_t;
module top(input logic clk, input logic [3:0] i, output logic [3:0] o);
  nib_t r = 4'h0;
  always_ff @(posedge clk) r <= i;
  assign o = r;
endmodule
