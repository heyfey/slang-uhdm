// § genLpOperandTsNoParent152
module top(output int o);
   localparam int P [2] = '{3, 4};
   for (genvar i = 0 ; i < 1 ; i++) begin : a
      if (1) begin : b
         localparam int L = P[1];
         assign o = L;
      end
   end
endmodule
