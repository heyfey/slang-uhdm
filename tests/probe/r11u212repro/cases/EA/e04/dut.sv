// § pkgEnumAliasListingParent212 — a $unit alias of a $unit enum typedef
typedef enum { A, B, C } e_t;
typedef e_t f_t;
module dut(input logic i, output logic o);
  f_t v;
  assign o = i;
endmodule
