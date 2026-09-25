// § foldedBoundTsRefUnstored144
module top(input logic [5:0] a, output int o);
   localparam int D = 5;
   typedef struct packed { logic [D:0] m; } s_t;
   s_t v;
   assign v.m = a;
   assign o = int'(v.m);
endmodule
