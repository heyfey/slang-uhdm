// § tpCastOverrideKeepsDefault407
module m #(parameter type T = int, parameter T D = T'(5)) (output T o);
  assign o = D;
endmodule
module top(output logic [3:0] o);
  m #(.T(logic [3:0])) u(o);
endmodule
