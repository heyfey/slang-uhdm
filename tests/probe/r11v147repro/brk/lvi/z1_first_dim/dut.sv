// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, output logic [1:0][3:0] w);
  always_comb begin
    w = '0;
    w[b[1]][0] = 1'b1;
  end
endmodule
