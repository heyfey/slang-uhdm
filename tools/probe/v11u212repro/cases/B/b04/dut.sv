// § pkgEnumAliasListingParent212 — verifier: the alias as a package class property type
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  class k;
    f_t mode;
    function new(); mode = B; endfunction
  endclass
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
