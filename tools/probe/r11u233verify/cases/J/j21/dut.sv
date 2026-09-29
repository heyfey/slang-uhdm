// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an int cast of an untyped struct parameter inside a pattern ('{x: int'(B)})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t B = '{x: 16};
   parameter info_t Info = '{x: int'(B)};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
