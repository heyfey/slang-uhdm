// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v ('x onto a typed pattern with a default key)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'{default: 16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = 'x;
   assign o = int'(data);
endmodule
