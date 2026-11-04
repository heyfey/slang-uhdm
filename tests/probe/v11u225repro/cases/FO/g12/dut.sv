// § initHierFillKept225 — fresh: a program's signal written by '1 (program scope)
program pr(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  logic [N-1:0] data;
  assign data = '1;
  assign o = int'(data);
endprogram
module top(output int o);
  pr u(.o(o));
endmodule
