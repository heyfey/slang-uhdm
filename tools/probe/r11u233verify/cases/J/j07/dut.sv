// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an untyped pattern with a unary member ('{x: +16})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: +16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
