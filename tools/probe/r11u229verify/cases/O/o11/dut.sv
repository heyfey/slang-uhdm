// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v ('1 through a port: the child's port width from the parent's substituted localparam, two children)
module sub #(parameter int D = 8) (output logic [D-1:0] a);
   assign a = '1;
endmodule
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'{x: 16, y: 4};
   localparam int N = Info.x;
   localparam int M = Info.y;
   logic [N-1:0] d1;
   logic [M-1:0] d2;
   sub #(.D(N)) u1 (.a(d1));
   sub #(.D(M)) u2 (.a(d2));
   assign o = int'(d1) + int'(d2);
endmodule
