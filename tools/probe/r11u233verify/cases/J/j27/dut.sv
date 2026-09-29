// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a concatenation holding a conditional of literals
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = {16'd0, SEL ? 16'd16 : 16'd9};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
