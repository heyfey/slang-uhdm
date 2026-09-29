// § initHierFillKept225 — fresh: the row's shape with an assignment-pattern struct parameter (golden reduces the member)
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule
