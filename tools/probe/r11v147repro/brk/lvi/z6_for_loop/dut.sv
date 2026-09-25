// § lvIdxBitSelAtIndex147
module top (input logic [1:0] b [4], output logic [3:0] w);
  always_comb begin
    w = '0;
    for (int i = 0; i < 4; i++)
      w[b[i]] = 1'b1;
  end
endmodule
