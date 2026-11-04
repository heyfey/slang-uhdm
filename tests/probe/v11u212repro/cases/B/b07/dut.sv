// § pkgEnumAliasListingParent212 — verifier: the alias typing a module port through a wildcard import, continuously assigned from a constant
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t;
endpackage
module dut import p::*; (input logic i, output f_t o);
  assign o = i ? B : C;
endmodule
