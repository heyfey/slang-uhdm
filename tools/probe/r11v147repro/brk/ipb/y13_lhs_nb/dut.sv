// § vsIpsBaseNamesByIps147
module top (input logic clk, input logic [2:0] k, output logic [1:0][7:0] w);
  always_ff @(posedge clk) begin : blk
    w[1][k + 1 +: 2] <= 2'b11;
  end
endmodule
