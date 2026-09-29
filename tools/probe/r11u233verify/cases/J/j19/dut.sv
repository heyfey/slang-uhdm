// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — two hops through members, the far root a cast ('{x: B.x}, B = '{x: C.x}, C cast)
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t C = info_t'(16);
   parameter info_t B = '{x: C.x};
   parameter info_t Info = '{x: B.x};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
