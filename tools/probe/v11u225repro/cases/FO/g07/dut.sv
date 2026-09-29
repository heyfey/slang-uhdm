// § initHierCaLhsBareName225 — fresh: a signal read by a continuous assignment and written by a process (not a whole left side)
module top(output int o, input logic clk);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  logic [N-1:0] data;
  always_ff @(posedge clk) data <= data + 1'b1;
  assign o = int'(data);
endmodule
