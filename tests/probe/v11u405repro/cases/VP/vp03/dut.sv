// § implicitPortPaLastNoBody405
module m #(parameter a = 1, b = 2) (output int o);
  assign o = a + b;
endmodule
module top(output int o);
  m #(4, 5) u(o);
endmodule
