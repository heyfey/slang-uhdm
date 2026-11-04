// § pkgEnumAliasListingParent212 — verifier: the alias as a package-qualified module variable type without an import
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t;
endpackage
module dut(input logic [1:0] i, output logic o);
  p::f_t v;
  always_comb v = p::f_t'(i);
  assign o = v == p::B;
endmodule
