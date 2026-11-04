// § initHierFillKept225 — fresh: 'x onto a substituted-width net at module scope
module top(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  logic [N-1:0] data;
  assign data = 'x;
  assign o = int'(data);
endmodule
