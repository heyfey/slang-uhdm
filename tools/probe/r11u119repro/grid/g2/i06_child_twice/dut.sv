module c (input logic i, output logic o);
  assign o = i;
endmodule
module m (input logic x, output logic y);
  c u1(.i(x), .o(n));
  c u2(.i(n), .o(y));
endmodule
module top (input logic x, output logic y, z);
  m a(.x(x), .y(y));
  m b(.x(x), .y(z));
endmodule
