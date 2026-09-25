// § lvIdxBitSelAtIndex147
module top (input logic en, input logic d, input logic [2:0] b, output logic [7:0] w);
  always_latch begin
    if (en) w[b[2]] = d;
  end
endmodule
