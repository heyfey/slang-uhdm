// § memberInitReducedRootFolds228 — a positional typed pattern (the substitution stays)
module top(output int o);
   typedef struct packed { int x; int y; } info_t;
   parameter info_t Info = info_t'{16, 8};
   localparam int N = Info.y;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
