// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (two signals in one declaration, the first written by '1, the second from it)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'{x: 16, y: 2};
   localparam int N = Info.x;
   logic [N-1:0] d, e;
   assign d = '1;
   assign e = d;
   assign o = int'(e);
endmodule
