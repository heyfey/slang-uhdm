// § defGenConnVarSelRange424
module m #(parameter w = 2) (output [w-1:0] p); endmodule
module top (output logic [3:0][4:0] pa);
  for (genvar i = 0; i < 2; i++) begin : g
    m #(.w(4)) u (.p(pa[i][3:0]));
  end
endmodule
