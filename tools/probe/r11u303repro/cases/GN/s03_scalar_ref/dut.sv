// § genNdaSelRhsSharesNet303
module top (input logic [63:0] arr, input logic [7:0] b, c, input logic d, output logic o);
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    wire w = d;
  end
  assign o = arr[0];
endmodule
