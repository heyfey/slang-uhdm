// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (a typed pattern whose member is another parameter)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter int W = 16;
   parameter part_info_t Info = part_info_t'{x: W, y: 2};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
