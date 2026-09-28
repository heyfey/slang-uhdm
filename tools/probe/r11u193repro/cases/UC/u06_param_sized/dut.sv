// § caUnsizedRhsClonePerInst193
module m #(parameter int W = 4) (input logic c, input logic [W-1:0] x);
  logic [W-1:0] arr [2];
  assign arr[0] = c ? x : '0;
endmodule
module top (input logic c, input logic [3:0] x, input logic [7:0] y);
  m u_a (.c(c), .x(x));
  m #(.W(8)) u_b (.c(c), .x(y));
endmodule
