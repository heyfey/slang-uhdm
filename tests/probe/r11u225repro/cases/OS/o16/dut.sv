// § initHierCaLhsBareName225 — inside a generate block
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   if (1) begin : g
     logic [N-1:0] d;
     assign d = '1;
   end
   assign o = int'(g.d);
endmodule : top
