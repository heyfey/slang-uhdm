// § initHierCaLhsBareName225 — fresh: the whole-signal continuous assignment inside a generate block
module top(output int o);
  typedef struct packed { int x; } info_t;
  parameter info_t Info = info_t'(16);
  localparam int N = Info.x;
  logic [N-1:0] data;
  if (1) begin : g
    assign data = '1;
  end
  assign o = int'(data);
endmodule
