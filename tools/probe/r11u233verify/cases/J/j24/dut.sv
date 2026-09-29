// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an untyped pattern whose member is an arithmetic of literals ('{x: 8 + 8})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 8 + 8};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
