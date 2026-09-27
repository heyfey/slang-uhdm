// § enumImportParentLastWriter180 (verifier: file-scope import, two modules, the alphabetically last first in source)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
import p::*;
module zmod(input e_t i, output logic o);
  assign o = (i == B);
endmodule
module amod(input e_t i, output logic o);
  assign o = (i == C);
endmodule
module top(input logic [1:0] x, output logic y1, y2);
  zmod uz(.i(e_t'(x)), .o(y1));
  amod ua(.i(e_t'(x)), .o(y2));
endmodule
