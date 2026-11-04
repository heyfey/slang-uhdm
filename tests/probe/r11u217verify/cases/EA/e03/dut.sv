// § pkgEnumAliasListingParent212 — r11u217 e03: an alias of an enum typedef declared in ANOTHER package (`typedef q::e_t f_t;` in p), read by no importer, and a class property typed by the alias
package q;
  typedef enum logic [2:0] { X, Y, Z } e_t;
endpackage
package p;
  typedef q::e_t f_t;
  class k;
    f_t v;
  endclass
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
