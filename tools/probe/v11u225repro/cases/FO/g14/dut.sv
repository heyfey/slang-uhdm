// § initHierFillKept225 — fresh: a wire written by assign, and a variable of the same width written by '1 from another scope name
module top(output int o, output int p);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  wire [N-1:0] w;
  logic [N-1:0] v;
  assign w = '1;
  assign v = 16'hBEEF;
  assign o = int'(w);
  assign p = int'(v);
endmodule
