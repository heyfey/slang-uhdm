// § initHierAtRefToken225 — fresh: CRLF line endings, a top-level '1
module top(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  logic [N-1:0] data;
  assign data = '1;
  assign o = int'(data);
endmodule
