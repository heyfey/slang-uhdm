// § defGenConnVarSelRange424
module m #(parameter w = 2) (input [w-1:0] p); endmodule
module top (input logic [3:0][7:0] pa);
  genvar i;
  for (i = 0; i < 2; i++) begin : g
    m #(.w(4)) u (.p(pa[i][7:4]));
  end
endmodule
