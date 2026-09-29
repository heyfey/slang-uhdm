// § initHierCaLhsBareName225 — fresh: a typedef of the substituted width, the signal written by '1
module top(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  typedef logic [N-1:0] w_t;
  w_t data;
  assign data = '1;
  assign o = int'(data);
endmodule
