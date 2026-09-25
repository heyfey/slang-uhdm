// § lvIdxPathIsRead154
module top(input logic clk, input logic [7:0] d);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } a_t;
  typedef struct packed { a_t adr; } s_t;
  s_t s;
  logic [7:0] m [0:15];
  always_ff @(posedge clk) m[s.adr.lo] <= d;
endmodule
