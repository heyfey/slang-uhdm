// § foldedBoundTsRefUnstored144
module top(output int o);
   localparam int D = 5;
   logic [D:0] v;
   assign v = '0;
   assign o = int'(v);
endmodule
