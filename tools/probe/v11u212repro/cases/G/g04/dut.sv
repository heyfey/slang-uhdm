// § pkgEnumAliasListingParent212 — verifier: two package aliases in two packages of one file, both imported by a module
package pa;
  typedef enum { A, B, C } e_t;
  typedef e_t fa_t;
endpackage
package pb;
  import pa::*;
  typedef e_t fb_t;
endpackage
module dut(input logic i, output logic o);
  import pa::*;
  import pb::*;
  fb_t v;
  initial v = B;
  assign o = i;
endmodule
