// § genNdaSelRhsSharesNet303
module top (input logic [7:0] mem [4], output logic o);
  for (genvar i = 0; i < 2; ++i) begin : g
    wire [7:0] w = mem[i];
    wire x = mem[i][0];
  end
  assign o = 1'b0;
endmodule
