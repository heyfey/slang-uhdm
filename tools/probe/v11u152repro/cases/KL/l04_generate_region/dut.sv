// § genLpOperandTsNoParent152
module top(output int o);
   parameter int P [2]  = '{1, 2};
   generate
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int A = P[0];
      assign o = A;
   end
   endgenerate
endmodule
