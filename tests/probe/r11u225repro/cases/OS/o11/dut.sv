// § initHierCaLhsBareName225 — written by assign from a port: bare name
module top(input logic [3:0] i, output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] d5;
   assign d5 = i;
   assign o = int'(d5);
endmodule : top
