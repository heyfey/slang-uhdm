module c (input logic i, output logic o);
  assign o = i;
endmodule
module top (input logic x, output logic y);
  c u1(x, n);
  c u2(n, y);
endmodule
