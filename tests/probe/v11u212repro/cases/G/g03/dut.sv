// § pkgEnumAliasListingParent212 — verifier: a package alias written inside a macro body
`define ALIAS(a, b) typedef a b;
package p;
  typedef enum { A, B, C } e_t;
  `ALIAS(e_t, f_t)
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
