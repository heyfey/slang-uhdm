// § memberInitReducedRootFolds228 — an untyped pattern, a two-dimensional packed signal and an unpacked dimension
module top(output int o);
   typedef struct packed { int x; int y; } info_t;
   parameter info_t Info = '{x: 4, y: 3};
   localparam int N = Info.x;
   localparam int M = Info.y;
   logic [N-1:0][M-1:0] d2;
   logic [7:0] u [N];
   assign d2 = '0;
   assign o = int'(d2) + int'(u[0]);
endmodule
