// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire signed [7:0] y;
  wire [7:0] z;
  if (W <= 4) begin: g
    assign y = 1 - W;
    assign z = 1 - W;
  end
endmodule
