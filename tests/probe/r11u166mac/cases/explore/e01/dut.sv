// § ppOutputLine166 (exploratory seed)
`define TWO(a, b) \
  assign a = 1'b0; \
  assign b = 1'b1;
module top(output o, p, q, r);
  assign q = 1'b0; `TWO(o, p) assign r = 1'b1;
endmodule
