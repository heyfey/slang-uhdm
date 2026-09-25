// § foldedBoundTsRefUnstored144
module top(input logic [5:0] a, output int o);
   localparam int D = 5;
   logic [D:0] v, w;
   assign v = a;
   assign w = v;
   assign o = int'(w);
endmodule
