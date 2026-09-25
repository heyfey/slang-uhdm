// § lvIdxBitSelAtIndex147
module top (input logic clk, input logic [3:0] m, input logic [1:0] b [2], output logic [3:0] w);
  always_ff @(posedge clk) begin
    w[b[m[0]]] <= 1'b1;
  end
endmodule
