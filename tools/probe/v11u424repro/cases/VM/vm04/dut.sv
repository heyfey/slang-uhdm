// § defGenConnVarSelRange424
module m #(parameter w = 2) (output [w-1:0] p); endmodule
module top #(parameter W = 4) (output logic [3:0][7:0] pa);
  for (genvar i = 0; i < 2; i++) begin : g
    m #(.w(W)) u (.p(pa[i][(W-1):0]));
  end
endmodule
