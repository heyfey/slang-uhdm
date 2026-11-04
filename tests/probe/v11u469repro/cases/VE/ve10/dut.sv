// § importEnumCloneHomeInst469
// a pure chain of enum parameters: c imports b only, b imports a
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E2;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
endpackage
module top;
  logic w;
endmodule
