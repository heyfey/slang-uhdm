// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a concatenation wider than the struct with a subtraction ({16'd0, 32'd20 - 32'd4})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = {16'd0, 32'd20 - 32'd4};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
