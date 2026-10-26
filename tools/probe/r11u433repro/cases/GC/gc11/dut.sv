// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z);
  if (W > 1) begin: g
    assign y = W % 3 + 10;
    assign z = ~(W + 1);
  end
endmodule
