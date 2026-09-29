// § memberRootFoldShapes228v § memberInitReducedRootFolds228 — the struct parameter's value an int parameter (implicit conversion of a name)
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter int W = 13;
   parameter info_t Info = W;
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
