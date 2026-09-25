// § genLpOperandTsNoParent152
module top(output int o [3]);
   parameter int P [2]  = '{1, 2};
   for (genvar i = 0 ; i < 3 ; i++) begin
      localparam int A = P[0];
      assign o[i] = A;
   end
endmodule
