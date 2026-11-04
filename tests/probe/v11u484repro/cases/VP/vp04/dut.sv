// § aliasTdTargetTopView484 (package alias of an enum used by a module variable)
package u;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t e2_t;
endpackage
module top(output logic [1:0] o);
  import u::*;
  e2_t e;
  assign e = C;
  assign o = e;
endmodule
