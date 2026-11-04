// § genLpOperandTsNoParent152
module top(output int o [2]);
   parameter int P [2]  = '{3, 4};
   for (genvar i = 0 ; i < 2 ; i++) begin : g
      localparam int A = P[i];
      for (genvar j = 0 ; j < 1 ; j++) begin : h
        localparam int B = P[1];
        assign o[i] = A + B;
      end
   end
endmodule
