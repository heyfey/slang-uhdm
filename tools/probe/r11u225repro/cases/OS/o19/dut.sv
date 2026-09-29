// § initHierFillKept225 — '0 and 'z fills
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a, output logic [Depth-1:0] b);
   assign a = '0;
   assign b = 'z;
endmodule
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data, d2;
   sub #(.Depth(N)) u (.a(data), .b(d2));
   assign o = int'(data);
endmodule : top
