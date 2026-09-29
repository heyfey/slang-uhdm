// § memberInitReducedRootFolds228 — the member width scaled and summed in the bound
module top(output int o);
   typedef struct packed { int x; int y; } info_t;
   parameter info_t Info = '{x: 3, y: 2};
   localparam int N = Info.x;
   localparam int M = Info.y;
   logic [2*N+M-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
