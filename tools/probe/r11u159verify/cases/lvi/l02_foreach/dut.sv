// § lvIdxBitSelAtIndex147
module top (input logic [1:0] idx [4], output logic [3:0] w);
  always_comb begin
    w = '0;
    foreach (idx[k]) w[idx[k][0]] = 1'b1;
  end
endmodule
