// § ppOutputCol166
`define Z(x) \
  assign x = 1'b0;
module top(output o, p);
  `Z(o)   assign p = 1'b1;
endmodule
