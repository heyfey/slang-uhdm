// § pkgEnumAliasListingParent212 — r11u217 e02: two aliases of one enum in the package (`f_t`, `g_t`), an alias read by NO importer beside one read only by a package function
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  typedef e_t g_t;
  function automatic g_t nx(g_t x); return g_t'(x + 1); endfunction
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
