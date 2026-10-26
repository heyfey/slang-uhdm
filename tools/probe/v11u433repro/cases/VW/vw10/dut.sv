// § genCaConstRhsWhole433
module top #(parameter W = 4'd2, parameter V = 8'hF0) ();
  logic [7:0] y, z;
  if (W <= 4) begin: g
    assign y = W + 1;
    assign z = V | 8'h0F;
  end
endmodule
