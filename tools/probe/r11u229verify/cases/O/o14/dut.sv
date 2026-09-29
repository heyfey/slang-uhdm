// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (an untyped positional pattern, 'x onto a wire)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = '{16, 2};
   localparam int N = Info.x;
   wire [N-1:0] data;
   assign data = 'x;
   assign o = int'(data);
endmodule
