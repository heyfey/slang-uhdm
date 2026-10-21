// § defGenConnIpsExprBounds424 (control: the multiplication base the text parser already builds)
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter c = 2) (input [15:0] di);
  genvar i;
  for (i = 0; i < 2; i++) begin: g
    m #(.w(c)) u (.d(di[i*c+:c]));
  end
endmodule
