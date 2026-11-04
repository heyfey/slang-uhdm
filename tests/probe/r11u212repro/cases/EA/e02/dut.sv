// § pkgEnumAliasListingParent212 — the alias typedef in a package, no use at all
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
