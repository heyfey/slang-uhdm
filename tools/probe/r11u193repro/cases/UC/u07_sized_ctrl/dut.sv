// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [3:0] x);
  logic [3:0] arr [2];
  assign arr[0] = c ? x : 4'd0;
endmodule
module top (input logic c, input logic [3:0] x);
  m u_a (.c(c), .x(x));
endmodule
