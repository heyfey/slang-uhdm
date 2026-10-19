// § genLpUntypedDefNoTs410
module top #(parameter W = 4) (input logic [W-1:0] a, output logic [W-1:0] y);
  if (W > 2) begin : g
    localparam X = 4'b1010;
    localparam Z = X + W;
    assign y = a ^ Z[W-1:0];
  end
endmodule
