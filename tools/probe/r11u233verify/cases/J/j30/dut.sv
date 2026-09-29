// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an untyped pattern whose member is an int localparam of an arithmetic of literals ('{x: W}, W = 8 + 8)
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   localparam int W = 8 + 8;
   parameter info_t Info = '{x: W};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
