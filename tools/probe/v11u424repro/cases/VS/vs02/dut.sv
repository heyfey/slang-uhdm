// § defGenConnPsExprBounds424
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter W = 4, parameter C = 1) (input [15:0] di);
  if (1) begin : g
    m #(.w(W)) u (.d(di[W+C-2:C-1]));
  end
endmodule
