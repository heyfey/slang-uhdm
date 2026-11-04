// § defGenConnVarSelRange424
module m #(parameter w = 2) (output [w-1:0] p); endmodule
module top (output logic [3:0][4:0] pa);
  if (1) begin : g
    m #(.w(4)) u (.p(pa[1][3:0]));
  end
endmodule
