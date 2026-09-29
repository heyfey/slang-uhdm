// § initHierCaLhsBareName225 — control: written by a process keeps the scoped name
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] d3;
   always_comb d3 = '1;
   assign o = int'(d3);
endmodule : top
