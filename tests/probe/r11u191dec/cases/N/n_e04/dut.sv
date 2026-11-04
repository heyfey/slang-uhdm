// law enumImportParentLastWriter180 law enumImpDefOwner180v (r11u190: a wildcard and an explicit import of the enum in the same module, beside an explicit importer)
package p;
  typedef enum logic [1:0] {B0, B1, B2} e_t;
  typedef logic [3:0] n_t;
endpackage
module zmod;
  import p::*;
  import p::e_t;
  e_t x;
  n_t k;
endmodule
module amod;
  import p::e_t;
  e_t y;
endmodule
module top;
  amod ua();
  zmod uz();
endmodule
