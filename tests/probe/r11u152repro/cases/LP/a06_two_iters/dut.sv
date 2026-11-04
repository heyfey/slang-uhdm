// § genLpOperandTsNoParent152
module top(output int o [2]);
   parameter int P [2]  = '{1, 2};
   for (genvar i = 0 ; i < 2 ; i++) begin
      localparam int A = P[1];
      assign o[i] = A;
   end
endmodule
