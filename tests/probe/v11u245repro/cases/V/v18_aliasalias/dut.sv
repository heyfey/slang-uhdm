// § unitTdLawS245
// an alias of a $unit vector typedef on a variable and on a wire
typedef logic [3:0] nib_t;
typedef nib_t n2_t;
module top(input logic [3:0] i, output logic [3:0] o);
  n2_t v;
  wire nib_t w = v;
  assign v = i;
  assign o = w;
endmodule
