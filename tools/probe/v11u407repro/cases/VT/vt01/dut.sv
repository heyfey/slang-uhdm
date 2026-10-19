// § tpCastOverrideKeepsDefault407
module m #(parameter int W = 8, parameter type T = logic [W-1:0], parameter T D = T'(5)) (output T o);
  assign o = D;
endmodule
module top(output logic [3:0] o, output logic [7:0] p);
  m #(.W(2), .T(logic [3:0])) u(o);
  m #(.W(8)) v(p);
endmodule
