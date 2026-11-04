// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  typedef enum logic [1:0] {A, B, C} e_t;
  e_t y;
  if (W <= 4) begin: g
    assign y = e_t'(W);
  end
endmodule
