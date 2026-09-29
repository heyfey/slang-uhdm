// § initHierAtRefToken225 — a second member (Info.y)
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '0;
endmodule
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.y;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule : top
