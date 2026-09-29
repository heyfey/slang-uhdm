// § lvIdxPathRangeTailIsRead218 — an lvalue whose index is a two-level member path ending in a part select, with a second select after it
module top(input logic clk, input logic [7:0] x, input logic [15:0] a);
  typedef struct packed { logic [3:0] w; logic [3:0] z; } in_t;
  typedef struct packed { in_t i; logic [7:0] q; } out_t;
  out_t s;
  assign s = a;
  logic [7:0] mem [16][4];
  always_ff @(posedge clk) mem[s.i.w[3:0]][1] <= x;
endmodule
