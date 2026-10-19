// § genLpUntypedDefNoTs410
module top #(parameter int W = 4, parameter logic [3:0] V = 2) (input logic [W-1:0] a, output logic [W-1:0] y);
  if (W > 2) begin : g
    localparam X = W;
    localparam Y = V;
    if (W > 3) begin : h
      localparam Z = X + 1;
      assign y = a + Z[W-1:0] + Y[W-1:0];
    end
  end
endmodule
