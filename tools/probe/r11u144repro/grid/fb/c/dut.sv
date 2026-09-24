// § foldedBoundTsRefUnstored144
module top(output int o);
   localparam int D = 5;
   wire [D:0] v = '0;
   assign o = int'(v);
endmodule
