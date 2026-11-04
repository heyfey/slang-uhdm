// § enumImportParentLastWriter180 § enumImpHdrBranch180 (r11u190: the alphabetically last module imports an enum LITERAL in its HEADER)
package p;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
endpackage
module zlit import p::C2; (output logic [1:0] q);
  assign q = C2;
endmodule
module amod;
  import p::*;
  e_t y;
endmodule
module top(output logic [1:0] q);
  amod ua();
  zlit uz(q);
endmodule
