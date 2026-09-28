// § pkgEnumAliasListingParent212 — verifier: the alias as a package parameter type
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t f_t;
  parameter f_t DEF = C;
endpackage
module dut(input logic i, output logic o);
  assign o = i ^ (p::DEF == p::C);
endmodule
