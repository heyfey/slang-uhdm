// § lvIdxBitSelAtIndex147
module top (input logic clk, input logic [2:0] b, output logic [3:0] w);
  always_ff @(posedge clk) begin
    w[b[1:0]] <= 1'b1;
    w[b[2]] <= 1'b0;
  end
endmodule
