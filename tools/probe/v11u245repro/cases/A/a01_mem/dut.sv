// § unitArrTd245
// a synthesizable memory of a $unit fixed-array typedef, ranged form
typedef logic [7:0] mem_t [0:3];
module top(input logic clk, input logic [1:0] a, input logic [7:0] d, input logic we, output logic [7:0] q);
  mem_t m;
  always_ff @(posedge clk) if (we) m[a] <= d;
  assign q = m[a];
endmodule
