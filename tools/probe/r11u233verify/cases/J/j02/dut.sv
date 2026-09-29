// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an arithmetic of an untyped-pattern struct parameter (B + 0)
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t B = '{x: 16};
   parameter info_t Info = B + 0;
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
