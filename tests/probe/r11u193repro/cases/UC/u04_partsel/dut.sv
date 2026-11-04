// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [3:0] x);
  logic [7:0] v;
  assign v[7:4] = c ? x : 'z;
  assign v[3:0] = x & 4'hF;
endmodule
module top (input logic c, input logic [3:0] x);
  m u_a (.c(c), .x(x));
endmodule
