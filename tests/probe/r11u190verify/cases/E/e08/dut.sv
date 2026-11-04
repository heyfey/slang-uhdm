// § enumImportParentLastWriter180 § enumImpDefOwner180v (r11u190: two enums of one package, each explicitly imported by a different module, a wildcard importer between them)
package p;
  typedef enum logic [1:0] {G0, G1} a_e;
  typedef enum logic [1:0] {H0, H1, H2} b_e;
endpackage
module amod;
  import p::b_e;
  b_e u;
endmodule
module mmod;
  import p::*;
  a_e v;
  b_e w;
endmodule
module zmod;
  import p::a_e;
  a_e x;
endmodule
module top;
  amod ua();
  mmod um();
  zmod uz();
endmodule
