// § castTsNestSelIdxByChain310
typedef struct packed { logic [3:0] k; logic [7:0] f; } e_t;
module top(input logic clk, input logic [1:0] i, input logic [7:0] d, output logic [7:0] r);
  e_t sa [4]; logic [1:0] m [4];
  always_ff @(posedge clk) sa[2'(i)].f <= d;
  always_comb sa[m[2'(i)]].k = 4'd1;
  assign r = sa[0].f;
endmodule
