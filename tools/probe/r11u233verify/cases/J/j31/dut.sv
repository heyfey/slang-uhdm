// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a concatenation of literals wider than the struct ({16'd0, 16'd0, 16'd16})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = {16'd0, 16'd0, 16'd16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
