// § initHierFillKept225 — net declaration assignment of '1 (not reached: residue)
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   wire [N-1:0] d4 = '1;
   assign o = int'(d4);
endmodule : top
