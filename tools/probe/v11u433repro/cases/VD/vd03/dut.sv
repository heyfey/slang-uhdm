// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y);
  if (W <= 4) begin: g
    assign #1 y = W + 1;
  end
endmodule
