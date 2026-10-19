// § implicitPortPaLastNoBody405
module m #(a = 1, parameter b = 2) (output int o);
  assign o = a + b;
endmodule
module top(output int o);
  m u(o);
endmodule
