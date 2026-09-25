// § ppOutputLine166
`define ONE(x, y) assign x = y;
module top(input a, b, output o, p);
  assign p = a; `ONE(o, a |
      b)
endmodule
