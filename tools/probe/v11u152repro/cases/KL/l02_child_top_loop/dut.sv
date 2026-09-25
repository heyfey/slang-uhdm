// § genLpOperandTsNoParent152
module child(output int o);
   parameter int P [2]  = '{1, 2};
   for (genvar i = 0 ; i < 1 ; i++) begin
      localparam int A = P[1];
      assign o = A;
   end
endmodule
module top(output int o);
  child u(.o(o));
endmodule
