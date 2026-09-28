// § caUnsizedRhsClonePerInst193
module m (input logic [7:0] x);
  logic [7:0] arr [2];
  assign arr[0] = x | 'h1;
endmodule
module top (input logic [7:0] x);
  m u_a (.x(x));
endmodule
