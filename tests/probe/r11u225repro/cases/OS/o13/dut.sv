// § initHierCaLhsBareName225 — control: child port written by a process keeps the scoped name
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   always_comb a = '1;
endmodule
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule : top
