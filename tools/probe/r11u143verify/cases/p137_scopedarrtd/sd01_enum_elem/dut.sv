// § defNetScopedPkgArrTdShares137
// case sd01: a package-scoped unpacked-array typedef of an enum element
package sp2;
  typedef enum logic [1:0] {S0, S1, S2} e_t;
  typedef e_t ea[4];
endpackage
module dut(output logic [1:0] o);
  sp2::ea c;
  assign c[2] = sp2::S1;
  assign o = c[2];
endmodule
