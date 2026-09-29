// § initHierFillKept225 — fresh: the child written by '1 instantiated twice with the same member width
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module top(output int o, output int p);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] d1, d2;
   sub #(.Depth(N)) u1 (.a(d1));
   sub #(.Depth(N)) u2 (.a(d2));
   assign o = int'(d1);
   assign p = int'(d2);
endmodule
