module top (input logic x, z, output logic y);
  and g1(n, x, z);
  assign y = n;
endmodule
