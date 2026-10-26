// § genBodyDefBitsKeepsCall434
module top (output [3:0] y);
  logic [4:0] x;
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = x[$bits(x)-1-i];
  end
endmodule
