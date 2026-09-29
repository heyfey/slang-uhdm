// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (a localparam chain: N = A, A = Info.x)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'{x: 16, y: 2};
   localparam int A = Info.x;
   localparam int N = A;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
