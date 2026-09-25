// § ppOutputLine166
`define A2(x, y) assign x = y; \
  assign w = 1'b1; \
  assign v = 1'b0;
module top(input a, b, output o, w, v);
  `A2(o, a &
      b)
endmodule
