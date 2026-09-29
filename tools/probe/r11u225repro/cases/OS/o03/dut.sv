// § initHierCaLhsBareName225 — child internal net written by '1 and port written by it; § initHierFillKept225
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   logic [Depth-1:0] b;
   assign b = '1;
   assign a = b;
endmodule
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule : top
