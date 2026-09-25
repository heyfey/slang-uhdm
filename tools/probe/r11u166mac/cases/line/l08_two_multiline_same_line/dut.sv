// § ppOutputLine166
`define A(x) \
  assign x = 1'b0;
`define B(x) \
  assign x = 1'b1;
module top(output o, p, q);
  `A(o) `B(p) assign q = 1'b1;
endmodule
