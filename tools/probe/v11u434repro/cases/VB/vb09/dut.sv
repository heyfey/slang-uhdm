// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (output logic [7:0] y);
  logic [3:0] x;
  if (W > 1) begin : g
    assign y = {$bits(x){1'b1}};
  end
endmodule
