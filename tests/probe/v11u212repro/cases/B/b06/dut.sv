// § pkgEnumAliasListingParent212 — verifier: two packages each aliasing one enum typedef under the same name
package pa;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
endpackage
package pb;
  typedef pa::e_t f_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
