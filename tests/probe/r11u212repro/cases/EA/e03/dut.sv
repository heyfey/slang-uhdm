// § pkgEnumAliasListingParent212 — the alias typedef in a package imported by a module that declares a variable of it
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
endpackage
module dut(input logic i, output logic o);
  import p::*;
  f_t v;
  assign o = i;
endmodule
