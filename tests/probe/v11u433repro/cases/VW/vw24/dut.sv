// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  logic [3:0] x [3];
  if (W <= 4) begin: g
    assign y = $size(x);
  end
endmodule
