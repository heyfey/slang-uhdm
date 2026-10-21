// § defGenConnIpsExprBounds424
module m #(parameter w = 2) (output [w-1:0] d); endmodule
module top #(parameter W = 4) (output [15:0] dout);
  for (genvar i = 0; i < 2; i++) begin : g
    m #(.w(W)) u (.d(dout[W*i+W-1 -: W]));
  end
endmodule
