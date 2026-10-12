// § genNdaOpRhsFreshNet303
module top (input logic [63:0] arr, input logic [7:0] b, c, input logic d, output logic o);
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    wire [1:0] w2 = {b[0], c[0]}; wire w = w2[0];
  end
  assign o = arr[0];
endmodule
