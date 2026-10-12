// § genNdaOpRhsFreshNet303
module top #(parameter int P = 42405) (input logic [63:0] arr, input logic [7:0] b, c, input logic s, output logic o);
  if (1) begin : g
    wire [1:0] w = {1'b0, b == c};
  end
  assign o = arr[0];
endmodule
