// § foldedBoundTsRefUnstored144
module top(output int o);
   localparam int D = 5;
   for (genvar i = 0; i < 1; i++) begin : g
     logic [D:0] v;
     assign v = '0;
     assign o = int'(v);
   end
endmodule
