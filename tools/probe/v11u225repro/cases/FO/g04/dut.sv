// § initHierAtRefToken225 — fresh: two references in one range and a scaled reference
module top(output int o, output int p);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(8);
  localparam int N = Info.x;
  logic [N+N-1:0] d2;
  logic [2*N-1:N] d3;
  assign d2 = '1;
  always_comb d3 = '0;
  assign o = int'(d2);
  assign p = int'(d3);
endmodule
