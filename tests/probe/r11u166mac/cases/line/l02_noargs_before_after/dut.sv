// § ppOutputLine166
`define TWO \
  assign o = 1'b0; \
  assign p = 1'b1;
module top(output o, p, q, r);
  assign q = 1'b0; `TWO assign r = 1'b1;
endmodule
