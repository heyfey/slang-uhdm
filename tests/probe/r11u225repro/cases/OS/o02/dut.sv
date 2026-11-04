// § initHierAtRefToken225 — top only: [N-1:0] and [N:0]
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   logic [N:0] d2;
   assign o = int'(data) + int'(d2);
endmodule : top
