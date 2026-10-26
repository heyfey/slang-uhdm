// § genCaConstRhsWhole433
module top #(parameter W = 2) ();
  typedef struct packed { logic [2:0] a; logic [2:0] b; } s_t;
  s_t y;
  if (W <= 4) begin: g
    assign y = W + 70;
  end
endmodule
