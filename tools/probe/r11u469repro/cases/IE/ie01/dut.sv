// § importEnumCloneHomeInst469
// an enum-typed package parameter wildcard-imported by a second package
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
