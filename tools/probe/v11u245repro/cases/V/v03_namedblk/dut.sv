// § unitTdLawS245
// a $unit vector typedef on a variable of a named block in always_comb
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  always_comb begin : b
    nib_t t;
    t = i;
    o = t;
  end
endmodule
