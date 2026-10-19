// § tpCastOverrideKeepsDefault407
module m #(parameter type T = int, parameter int D = T'(5)) (output int o);
  assign o = D;
endmodule
module top(output int o, output int p);
  m #(.T(shortint)) u(o);
  m #(.T(byte)) v(p);
endmodule
