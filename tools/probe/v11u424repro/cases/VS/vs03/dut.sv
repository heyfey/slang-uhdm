// § defGenConnPsExprBounds424
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter W = 4) (input [15:0] di);
  if (1) begin : g
    m #(.w($clog2(W)+1)) u (.d(di[$clog2(W):0]));
  end
endmodule
