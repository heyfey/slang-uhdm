// § foldedBoundTsRefUnstored144
module top(a, o);
   parameter int D = 5;
   input logic [D:0] a;
   output int o;
   assign o = int'(a);
endmodule
