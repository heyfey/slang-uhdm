// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (the member read under a cast: not a bare member initializer)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'{x: 16, y: 2};
   localparam int N = int'(Info.x);
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
