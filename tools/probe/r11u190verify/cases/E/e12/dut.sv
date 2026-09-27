// § enumImportParentLastWriter180 (r11u190: the alphabetically last module imports an enum literal AND wildcard-imports the package)
package p;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
endpackage
module zlit(output logic [1:0] q);
  import p::C1;
  import p::*;
  e_t r;
  assign q = C1;
endmodule
module amod;
  import p::*;
  e_t y;
endmodule
module top(output logic [1:0] q);
  amod ua();
  zlit uz(q);
endmodule
