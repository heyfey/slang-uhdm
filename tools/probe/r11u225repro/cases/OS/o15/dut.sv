// § initHierAtRefToken225 — a package struct parameter
package p;
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(12);
endpackage
module top(output int o);
   localparam int N = p::Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule : top
