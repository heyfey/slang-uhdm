// § defGenConnPsExprBounds424
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter W = 4) (input [15:0] di);
  for (genvar i = 0; i < 2; i++) begin : g
    m #(.w(W)) u (.d(di[W*(i+1)-1:W*i]));
  end
endmodule
