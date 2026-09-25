// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, input logic [3:0] x, output logic [3:0] w [4]);
  always_comb begin
    w = '{default: '0};
    w[b[1:0]] = x;
    w[b[2]][1] = 1'b0;
  end
endmodule
