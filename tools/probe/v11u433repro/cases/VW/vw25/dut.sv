// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [63:0] y, z);
  if (W <= 4) begin: g
    assign y = W + 3000000000;
    assign z = 3000000000;
  end
endmodule
