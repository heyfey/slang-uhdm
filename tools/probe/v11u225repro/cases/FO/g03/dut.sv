// § initHierFillKept225 — fresh: a struct typedef member with the substituted width shares its name with a plain signal written by '1
module top(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  typedef struct packed { logic [N-1:0] data; } s_t;
  s_t s;
  logic [7:0] data;
  assign data = '1;
  always_comb s = '0;
  assign o = int'(data) + int'(s.data);
endmodule
