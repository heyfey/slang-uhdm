// § genCaConstRhsWhole433
module top #(parameter int W = 2) ();
  logic [7:0] y;
  if (W <= 4) begin: g
    assign y = W + 1;
  end
endmodule
