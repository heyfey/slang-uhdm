// § defNetScopedPkgArrTdShares137
// case sd02: a package-scoped unpacked-array typedef as a sub-module port type
package sp3;
  typedef logic [3:0] b[2];
endpackage
module sub(input sp3::b x, output logic [3:0] o); assign o = x[1]; endmodule
module dut(output logic [3:0] o);
  sp3::b c;
  assign c[0] = 4'h1;
  assign c[1] = 4'h2;
  sub u(.x(c), .o(o));
endmodule
