// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (a package struct type, a wire written by '1)
package pk;
   typedef struct packed { int x; int y; } part_info_t;
endpackage
module top(output int o);
   parameter pk::part_info_t Info = pk::part_info_t'{x: 16, y: 2};
   localparam int N = Info.x;
   wire [N-1:0] w;
   assign w = '1;
   assign o = int'(w);
endmodule
