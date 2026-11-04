// § genCaConstRhsWhole433
module top #(parameter W = 2, parameter [5:0] V = 1) (output [31:0] y, z, output [7:0] p);
  if (W > 1) begin: g
    assign y = $bits(W);
    assign z = $bits(V);
    assign p[6:0] = $bits(V);
  end
endmodule
