// § initHierCaLhsBareName225 — 'x fill onto the child port, [Depth:0]
module sub #(parameter int Depth = 128) (output logic [Depth:0] a);
   assign a = 'x;
endmodule
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule : top
