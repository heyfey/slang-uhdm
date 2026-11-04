// G2 (N1129): a module's own unpacked int array parameter initialized by a
// concatenation, in a sub-instance.
module sub(output int o);
  parameter int A3[0:2] = {1, 2, 3};
  assign o = A3[2];
endmodule
module top(output int o);
  sub u(.o(o));
endmodule
