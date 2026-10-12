// § genNdaSelConstReduces303v
module top #(parameter int P = 42405) (input logic [63:0] arr, input logic [7:0] b, c, input logic s, output logic o);
  for (genvar i = 0; i < 2; ++i) begin : g
    wire [3:0] w = P[i*4 +: 4];
  end
  assign o = arr[0];
endmodule
