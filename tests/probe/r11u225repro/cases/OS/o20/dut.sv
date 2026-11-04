// § initHierCaLhsBareName225 — an interface instance overridden from the struct member
interface bi #(parameter int W = 4);
   logic [W-1:0] v;
   assign v = '1;
endinterface
module top(output int o);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   bi #(.W(N)) u();
   assign o = int'(u.v);
endmodule : top
