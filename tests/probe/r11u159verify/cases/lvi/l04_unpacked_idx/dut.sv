// § lvIdxBitSelAtIndex147
module top (input logic [2:0] m [2][2], output logic [7:0] w);
  always_comb begin
    w = '0;
    w[m[1][0]] = 1'b1;
  end
endmodule
