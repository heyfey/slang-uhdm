// § initHierFillKept225 — fresh: two members of a cast-initialized struct parameter, the child written by '1 instantiated with each
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module top(output int o, output int p);
   typedef struct packed { int x; int y; } info_t;
   parameter info_t Info = info_t'(64'h0000_0010_0000_0008);
   localparam int N = Info.x;
   localparam int M = Info.y;
   logic [N-1:0] d1;
   logic [M-1:0] d2;
   sub #(.Depth(N)) u1 (.a(d1));
   sub #(.Depth(M)) u2 (.a(d2));
   assign o = int'(d1);
   assign p = int'(d2);
endmodule
