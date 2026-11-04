// § blockLhsVarSelBindsWholeRef151 (the r11u151 ARR law this pass lands, composed with § lvIdxBitSelAtIndex147 and § vsIpsBaseNamesByIps147)
module top (input logic [2:0] b, output logic [1:0][7:0] o);
  logic [1:0][7:0] w;
  always_comb begin : blk
    w = '0;
    w[0][b] = 1'b1;
  end
  assign o = w;
endmodule
