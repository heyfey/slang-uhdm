// § pkgEnumAliasListingParent212 — verifier: a package alias of a class-scoped enum typedef
package p;
  class k;
    typedef enum { A, B } e_t;
  endclass
  typedef k::e_t f_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
