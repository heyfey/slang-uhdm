// § unitTdLawS245
// an unpacked array variable of a $unit vector typedef
typedef logic [3:0] nib_t;
module top(input logic [1:0] a, input logic [3:0] d, input logic clk, output logic [3:0] q);
  nib_t m [4];
  always_ff @(posedge clk) m[a] <= d;
  assign q = m[a];
endmodule
