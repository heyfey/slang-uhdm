// § enumImportParentLastWriter180 § enumImpDefOwner180v (r11u190: enum literals imported by two late-named modules, one of them also importing the typedef explicitly)
package p;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
endpackage
module ylit(output logic [1:0] q);
  import p::C1;
  import p::e_t;
  e_t r;
  assign q = C1;
endmodule
module zlit(output logic [1:0] q);
  import p::C2;
  assign q = C2;
endmodule
module amod;
  import p::*;
  e_t y;
endmodule
module top(output logic [1:0] q1, q2);
  amod ua();
  ylit uy(q1);
  zlit uz(q2);
endmodule
