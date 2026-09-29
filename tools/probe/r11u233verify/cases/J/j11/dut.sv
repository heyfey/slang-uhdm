// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an arithmetic of an int localparam initialized by a cast (W + 0, W = int'(16))
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   localparam int W = int'(16);
   parameter info_t Info = W + 0;
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
