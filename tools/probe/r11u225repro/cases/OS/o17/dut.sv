// § initHierCaLhsBareName225 — a select left side
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data[0] = 1'b1;
   assign o = int'(data);
endmodule : top
