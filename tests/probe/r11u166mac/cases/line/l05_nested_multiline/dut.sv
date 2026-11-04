// § ppOutputLine166
`define IN(x) \
  assign x = 1'b0; \
  assign w = 1'b1;
`define OUT(x, y) \
  assign y = 1'b1; \
  `IN(x) \
  assign v = 1'b0;
module top(output o, p, w, v);
  `OUT(o, p)
endmodule
