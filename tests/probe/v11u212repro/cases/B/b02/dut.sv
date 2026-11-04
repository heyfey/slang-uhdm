// § pkgEnumAliasListingParent212 — verifier: an alias of an alias in one package
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  typedef f_t g_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
