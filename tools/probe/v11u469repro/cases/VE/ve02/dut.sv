// § importEnumCloneHomeInst469
// the enum type is declared in a third package z, the parameter in a, b imports a
package z;
  typedef enum logic [1:0] {Z0, Z1, Z2} e_t;
endpackage
package a;
  import z::*;
  parameter e_t PE = Z2;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
