// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  if (W <= 4) begin: g
    assign y = W + 1;
  end
  wire [7:0] y;
endmodule
