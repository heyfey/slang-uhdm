// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z, output [3:0] q);
  if (W > 1) begin: g
    assign y = $bits(logic [3:0]);
    assign z = 4'bx1 + 1;
    assign q = W[3:0] + 1;
  end
endmodule
