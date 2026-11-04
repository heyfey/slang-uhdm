// § genCaConstRhsWhole433
module top #(parameter W = 2) (output logic [2:0] y);
  if (W <= 4) begin: g
    assign y = W * 7;
  end
endmodule
