// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (the second member of a typed pattern)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'{x: 3, y: 16};
   localparam int N = Info.y;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
