// § lvIdxBitSelAtIndex147
module top (input logic [1:0] b, output logic [3:0] w);
  always_comb begin
    w = '0;
    w[b] = 1'b1;
    w[1] = 1'b0;
  end
endmodule
