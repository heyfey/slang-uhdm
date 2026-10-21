// § defGenConnVarSelRange424
module m #(parameter w = 2) (output [w-1:0] p); endmodule
module top (output logic [1:0][3:0][4:0] pa);
  for (genvar i = 0; i < 2; i++) begin : g
    m #(.w(2)) u (.p(pa[i][i][i+1:i]));
  end
endmodule
