// § caUnsizedRhsClonePerInst193
module m (input logic c);
  logic s;
  logic [7:0] arr [2];
  assign arr[0] = c ? {8{s}} : '0;
endmodule
module top (input logic c);
  m u_a (.c(c));
  m u_b (.c(c));
endmodule
