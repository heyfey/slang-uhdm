// § defGenConnIpsExprBounds424
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter a_p = 3, parameter b_p = 1, parameter c = 2) (input [15:0] di);
  if (1) begin: ctrl
    m #(.w(c)) u (.d(di[(a_p+b_p)+:c]));
  end
endmodule
