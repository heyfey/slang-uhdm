// § castTsNestSelIdxByChain310
typedef struct packed { logic [3:0] k; logic [7:0] f; } e_t;
module top(input logic clk, input logic [1:0] i, input logic [7:0] d, output logic [7:0] r);
  e_t sa [4]; logic [1:0] m [4];
  for (genvar g = 0; g < 2; g++) begin : gb
    always_ff @(posedge clk) sa[2'(g)].f <= d;
    assign m[g] = sa[m[2'(g)]].k[1:0];
  end
  assign r = sa[0].f;
endmodule
