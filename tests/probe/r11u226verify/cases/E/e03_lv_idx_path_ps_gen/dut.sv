// § lvIdxPathRangeTailIsRead218 — an lvalue select whose index is a dotted path ending in a part select, in a generate loop and in a nonblocking always_ff, and a descending part select
module top(input logic clk, input logic [7:0] x, input logic [15:0] a);
  typedef struct packed { logic [7:0] lo; logic [7:0] hi; } s_t;
  s_t s;
  assign s = a;
  logic [7:0] mem [16];
  logic [7:0] m2 [8];
  for (genvar g = 0; g < 2; g++) begin : gg
    always_ff @(posedge clk) if (g == 0) mem[s.lo[3:0]] <= x;
  end
  always_ff @(posedge clk) m2[s.hi[6:4]] <= x;
endmodule
