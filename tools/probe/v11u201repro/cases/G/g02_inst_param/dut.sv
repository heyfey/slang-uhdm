// § genBlockBitsKeepsSelect200
module sub #(parameter int W = 1) (output logic [31:0] o);
  assign o = W;
endmodule
module top(input logic [15:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.W($bits(x[i+3:0]))) u(.o());
  end
  if (1) begin : h
    sub #(.W($bits(x[7:0]))) u2(.o(z));
  end
endmodule
