// § initHierFillKept225 — fresh: the child port written by '1, the child instantiated twice with two member widths
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module top(output int o, output int p);
   typedef struct packed { int x; int y; } info_t;
   parameter info_t Info = '{x: 16, y: 8};
   localparam int N = Info.x;
   localparam int M = Info.y;
   logic [N-1:0] d1;
   logic [M-1:0] d2;
   sub #(.Depth(N)) u1 (.a(d1));
   sub #(.Depth(M)) u2 (.a(d2));
   assign o = int'(d1);
   assign p = int'(d2);
endmodule
