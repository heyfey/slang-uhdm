// § defGenConnIpsExprBounds424
`define OFS (W/2)
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter W = 4) (input [15:0] di);
  if (1) begin : g
    m #(.w(W)) u (.d(di[`OFS +: W]));
  end
endmodule
