// § defGenConnIpsExprBounds424
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter a_p = 3, parameter c = 3) (input [15:0] di);
  genvar i;
  for (i = 0; i < 2; i++) begin: g
    m #(.w(c-1)) u (.d(di[i+:(c-1)]));
    m #(.w(2)) v (.d(di[i+:((a_p > i) ? 2 : 2)]));
  end
endmodule
