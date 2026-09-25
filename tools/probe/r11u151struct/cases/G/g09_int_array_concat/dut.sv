// G (N1129): BlackParrotComplex's `bottom`: an unpacked int array parameter
// initialized by a concatenation, read by element.
module top(output int o);
  parameter int A3[0:2] = {1, 2, 3};
  parameter A = A3[2];
  assign o = A;
endmodule
