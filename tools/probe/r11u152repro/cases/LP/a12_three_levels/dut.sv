// § genLpOperandTsNoParent152
module top(output int o);
   parameter int P [2]  = '{3, 4};
   for (genvar i = 0 ; i < 1 ; i++) begin
      for (genvar j = 0 ; j < 1 ; j++) begin
         for (genvar k = 0 ; k < 1 ; k++) begin
            localparam int L = P[1];
            assign o = L;
         end
      end
   end
endmodule
