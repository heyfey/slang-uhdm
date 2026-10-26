// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  integer y;
  byte b;
  if (W <= 4) begin: g
    assign y = W - 5;
    assign b = W + 300;
  end
endmodule
