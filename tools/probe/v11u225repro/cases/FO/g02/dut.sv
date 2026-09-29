// § initHierFillKept225 — fresh: a generate-block signal with the substituted width shares its name with a plain module-scope signal written by '1
module top(output int o, output int p);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  logic [7:0] data;
  assign data = '1;
  if (1) begin : g
    logic [N-1:0] data;
    always_comb data = '0;
  end
  assign o = int'(data);
  assign p = int'(g.data);
endmodule
