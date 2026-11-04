// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  for (genvar i = 0; i < 1; i++) begin: g
    assign y = W + 1;
  end
endmodule
