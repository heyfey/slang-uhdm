// § genBodyDefBitsKeepsCall434
module top #(parameter W = 2) (y);
  output [31:0] y;
  reg [4:0] x;
  generate
    if (W > 1) begin : g
      assign y = $bits(x);
    end
  endgenerate
endmodule
