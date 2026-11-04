// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  logic [3:0] y;
  if (W <= 4) begin: g
    assign y = 300;
  end
endmodule
