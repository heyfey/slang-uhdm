// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a parenthesized concatenation holding a cast (({info_t'(16)}))
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = ({info_t'(16)});
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
