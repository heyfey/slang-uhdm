// § initHierAtRefToken225 — fresh: unpacked dimensions referencing the substituted parameter
module top(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(4);
  localparam int N = Info.x;
  logic [7:0] mem [N];
  logic [N-1:0] q [2];
  assign q[0] = '1;
  always_comb mem[0] = 8'h1;
  assign o = int'(q[0]) + int'(mem[0]);
endmodule
