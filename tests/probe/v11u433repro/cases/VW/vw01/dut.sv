// § genCaConstRhsWhole433
typedef logic [5:0] t_t;
module top #(parameter W = 2) ();
  t_t y;
  if (W <= 4) begin: g
    assign y = W + 70;
  end
endmodule
