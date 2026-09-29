// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an untyped pattern of an int localparam read from a cast struct parameter's member ('{x: W}, W = B.x)
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t B = info_t'(16);
   localparam int W = B.x;
   parameter info_t Info = '{x: W};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
