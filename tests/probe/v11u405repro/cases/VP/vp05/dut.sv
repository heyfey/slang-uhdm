// § implicitPortPaLastNoBody405
module m #(a = 1, b = 2) (output int o);
  assign o = a + b;
endmodule
module top(output int o);
  m #(.b(6)) u(o);
endmodule
