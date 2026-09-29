// § memberInitReducedRootFolds228 — CRLF line endings, an untyped pattern
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 7};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
