// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v (the struct parameter overridden at the instance by a typed pattern)
package pk;
   typedef struct packed { int x; int y; } part_info_t;
endpackage
module sub;
   parameter pk::part_info_t Info = pk::part_info_t'{x: 16, y: 2};
   localparam int N = Info.x;
   logic [N-1:0] d;
   assign d = '1;
endmodule
module top;
   sub #(.Info(pk::part_info_t'{x: 8, y: 2})) u();
endmodule
