module c (i, o);
  input i; output o;
  assign o = i;
endmodule
module top (x, y);
  input x; output y;
  c u1(.i(x), .o(w1));
  c u2(.i(w1), .o(y));
endmodule
