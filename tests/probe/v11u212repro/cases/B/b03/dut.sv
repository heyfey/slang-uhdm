// § pkgEnumAliasListingParent212 — verifier: the alias as a package struct member type
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t;
  typedef struct packed { f_t k; logic z; } s_t;
endpackage
module dut(input logic [2:0] i, output logic o);
  p::s_t v;
  always_comb v = i;
  assign o = v.z;
endmodule
