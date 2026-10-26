// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y, z;
  if (W <= 4) begin: g
    assign y = W && 1;
    assign z = W != 2;
  end
endmodule
