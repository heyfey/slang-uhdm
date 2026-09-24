// § defNetScopedPkgArrTdShares137
// case sd05: a package-scoped array typedef with a bit-vector element
package sp9;
  typedef bit [7:0] b[3];
endpackage
module dut(output logic [7:0] o);
  sp9::b c;
  assign c[1] = 8'h11;
  assign o = c[1];
endmodule
