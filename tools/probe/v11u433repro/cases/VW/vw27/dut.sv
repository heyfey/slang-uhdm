// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire y;
  wire [0:3] r;
  if (W <= 4) begin: g
    assign y = W + 1;
    assign r = W + 13;
  end
endmodule
