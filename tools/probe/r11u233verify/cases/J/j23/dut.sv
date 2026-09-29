// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a concatenation holding an int localparam ({16'd0, W})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   localparam logic [15:0] W = 16;
   parameter info_t Info = {16'd0, W};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
