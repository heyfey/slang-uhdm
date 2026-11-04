// § enumImportParentLastWriter180 (r11u190: the alphabetically last module imports only an enum LITERAL, not the typedef)
package p;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
endpackage
module zlit(output logic [1:0] q);
  import p::C1;
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
