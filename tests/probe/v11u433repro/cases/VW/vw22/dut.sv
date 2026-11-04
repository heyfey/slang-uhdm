// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  if (W <= 4) begin: g
    assign y = ~W;
  end
endmodule
