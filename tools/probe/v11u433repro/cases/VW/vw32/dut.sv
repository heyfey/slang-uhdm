// § genCaConstRhsWhole433
module top #(parameter W = 2) (y);
  output [7:0] y;
  if (W <= 4) begin: g
    assign y = W + 1;
  end
endmodule
