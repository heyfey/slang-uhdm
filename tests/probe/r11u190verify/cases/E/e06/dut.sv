// § enumImportParentLastWriter180 § enumImpDefOwner180v (r11u190: the winning importer casts to the enum; the other importer declares a variable)
package p;
  typedef enum logic [1:0] {D0, D1, D2} e_t;
endpackage
module zmod(input logic [1:0] r, output logic [1:0] q);
  import p::*;
  e_t x;
  always_comb x = e_t'(r);
  assign q = x;
endmodule
module amod;
  import p::*;
  e_t y;
endmodule
module top(input logic [1:0] r, output logic [1:0] q);
  amod ua();
  zmod uz(r, q);
endmodule
