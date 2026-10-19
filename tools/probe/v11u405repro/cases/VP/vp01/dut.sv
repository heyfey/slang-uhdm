// § implicitPortPaLastNoBody405
module m #(a = 1, localparam b = a * 2) (output int o);
  assign o = a + b;
endmodule
module top(output int o);
  m #(.a(3)) u(o);
endmodule
