// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [3:0] x);
  logic [3:0] a, b;
  assign {a, b} = c ? {x, x} : '1;
endmodule
module top (input logic c, input logic [3:0] x);
  m u_a (.c(c), .x(x));
endmodule
