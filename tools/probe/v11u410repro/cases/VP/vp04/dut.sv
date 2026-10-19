// § parenCastNameUnsupTs410
module top #(parameter W = 8) (input logic [7:0] x, output logic [7:0] y);
  if (W > 1) begin : g
    localparam H = W/2;
    assign y = (H)'(x);
  end
endmodule
