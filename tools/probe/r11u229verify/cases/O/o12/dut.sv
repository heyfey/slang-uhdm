// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (the struct parameter a bare reference to a typed-pattern localparam)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   localparam part_info_t I0 = part_info_t'{x: 16, y: 2};
   parameter part_info_t Info = I0;
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
