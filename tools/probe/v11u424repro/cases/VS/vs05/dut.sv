// § defGenConnPsExprBounds424
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter W = 4) (input [15:0] di);
  if (1) begin : g
    m #(.w(W)) u (.d(di[W-1:0]));
    m #(.w(W)) v (.d(di[2*W-1:W]));
  end
endmodule
