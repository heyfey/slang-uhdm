// § pkgEnumAliasListingParent212 — a module-scope alias of a module-scope enum typedef
module dut(input logic i, output logic o);
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  f_t v;
  assign o = i;
endmodule
