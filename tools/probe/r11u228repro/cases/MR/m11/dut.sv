// § memberInitReducedRootFolds228 — the pattern written by a macro
`define INFO_V '{x: 10}
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = `INFO_V;
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
