// § genLpOperandTsNoParent152
module top(output int o);
   parameter int P [2]  = '{3, 4};
   parameter bit S = 0;
   if (S) begin : a
     assign o = 0;
   end else begin : b
     for (genvar j = 0 ; j < 1 ; j++) begin : h
        localparam int B = P[1];
        assign o = B;
     end
   end
endmodule
