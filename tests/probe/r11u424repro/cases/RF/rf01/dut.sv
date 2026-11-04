// § defGenConnIpsExprBounds424 (pass 421 residue rf01)
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter width_p = 8, parameter c = 2) (input [width_p-1:0] di);
  if (1) begin: ctrl
    m #(.w(c)) u (.d(di[(width_p-1)-:c]));
  end
endmodule
