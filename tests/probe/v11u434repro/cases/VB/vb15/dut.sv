// § genBodyDefSysArgCallTree434
module top #(parameter W = 8) (input logic [7:0] a, output logic [31:0] y);
  if (W > 1) begin : g
    assign y = $unsigned($signed(a));
  end
endmodule
