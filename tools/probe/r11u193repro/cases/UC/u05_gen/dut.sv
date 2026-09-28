// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [3:0] x);
  logic [3:0] arr [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign arr[i] = c ? x : '0;
  end
endmodule
module top (input logic c, input logic [3:0] x);
  m u_a (.c(c), .x(x));
endmodule
