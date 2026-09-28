module top (input int x, output int o, output int q);
  assign o = pa::f(.a(x), .c(3));
  always_comb q = pa::f(.c(x), .a(1));
endmodule
