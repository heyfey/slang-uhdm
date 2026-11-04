// § initHierCaLhsBareName225 — a concatenation left side
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] d1, d2;
   assign {d1, d2} = '1;
   assign o = int'(d1) + int'(d2);
endmodule : top
