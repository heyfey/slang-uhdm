// § tpCastOverrideKeepsDefault407
module m #(parameter type T = logic [7:0], parameter T D = T'(5)) (output T o);
  assign o = D;
endmodule
module top(output logic [7:0] p);
  m v(p);
endmodule
