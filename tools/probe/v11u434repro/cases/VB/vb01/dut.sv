// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic y);
  logic [4:0] x;
  if (W <= 4)
    assign y = x[$bits(x)-1];
endmodule
