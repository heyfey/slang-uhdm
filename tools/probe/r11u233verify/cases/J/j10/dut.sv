// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an untyped pattern whose member is an arithmetic of a struct parameter's member ('{x: B.x + 0})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t B = info_t'(16);
   parameter info_t Info = '{x: B.x + 0};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
