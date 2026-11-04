// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, output logic [7:0] o);
  logic [7:0] w;
  always_comb begin : blk
    w = '0;
    w[{b[2], 2'b00}+:4] = '1;
  end
  assign o = w;
endmodule
