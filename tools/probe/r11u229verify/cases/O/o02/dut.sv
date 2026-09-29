// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (an expression bound 2*N-1 of the substituted localparam)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'(64'h0000_0010_0000_0002);
   localparam int N = Info.x;
   logic [2*N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
