// § lvIdxBitSelAtIndex147
module top (input logic clk, input logic [1:0] m, input logic [3:0] b, output logic [7:0] w);
  always_ff @(posedge clk) begin
    case (m)
      2'd0: w[b[1]] <= 1'b1;
      default: w[b[3]] <= 1'b0;
    endcase
  end
endmodule
