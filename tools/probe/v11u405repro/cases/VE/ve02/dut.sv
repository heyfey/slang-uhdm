// § tpCastBeforeTpListed405
module m #(parameter type T = int, parameter T D = T'(-1)) (output T o);
  assign o = D;
endmodule
module top(output int o);
  m u(o);
endmodule
