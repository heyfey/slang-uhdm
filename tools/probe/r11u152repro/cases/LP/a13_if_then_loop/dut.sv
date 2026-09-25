// § genLpOperandTsNoParent152
module top(output int o [1]);
   parameter int P [2]  = '{3, 4};
   if (1) begin : g
      for (genvar i = 0 ; i < 1 ; i++) begin
         localparam int L = P[1];
         assign o[i] = L;
      end
   end
endmodule
