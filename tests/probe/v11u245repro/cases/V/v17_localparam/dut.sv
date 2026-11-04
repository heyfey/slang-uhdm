// § unitTdLawS245
// a localparam typed by a $unit vector typedef beside a variable of it
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  localparam nib_t P = 4'h3;
  nib_t v;
  assign v = i + P;
  assign o = v;
endmodule
