// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (a concatenation of two sized integers)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = {32'd16, 32'd2};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
