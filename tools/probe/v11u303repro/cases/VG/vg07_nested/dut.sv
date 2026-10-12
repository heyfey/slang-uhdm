// § genNdaSelRhsSharesNet303
module top #(parameter int P = 42405) (input logic [63:0] arr, input logic [7:0] b, c, input logic s, output logic o);
  for (genvar i = 0; i < 2; ++i) begin : g
    for (genvar j = 0; j < 2; ++j) begin : h
      wire [1:0] w = arr[2*j+1 -: 2];
    end
  end
  assign o = arr[0];
endmodule
