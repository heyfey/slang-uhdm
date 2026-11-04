// § unitTdLawS245
// a $unit vector typedef on a wire with a declaration assignment
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  wire nib_t w = i;
  assign o = w;
endmodule
