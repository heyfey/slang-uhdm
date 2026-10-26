// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  wire [7:0] y;
  if (W <= 4) begin: g
    localparam L = W * 2;
    assign y = L + 1;
  end
endmodule
