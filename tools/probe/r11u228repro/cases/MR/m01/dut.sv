// § memberInitReducedRootFolds228 — an untyped pattern struct parameter, the member width signal only read
module top(input logic [15:0] i, output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = i;
   assign o = int'(data);
endmodule
