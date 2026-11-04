// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, input logic [1:0] x, output logic [3:0] w, output logic y);
  always_comb begin
    w = '0;
    {w[b[1]], y} = x;
  end
endmodule
