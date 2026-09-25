// § genLpOperandTsNoParent152
module top(output int o [2]);
   parameter int P [2] = '{5, 6};
   for (genvar i = 0 ; i < 2 ; i++) begin : a
      for (genvar j = 0 ; j < 1 ; j++) begin : b
         localparam int L = P[i];
         assign o[i] = L;
      end
   end
endmodule
