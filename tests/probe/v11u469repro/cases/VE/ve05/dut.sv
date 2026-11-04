// § importEnumCloneHomeInst469
// the importer declares its own parameter of the imported enum type
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
package b;
  import a::*;
  parameter e_t PB = E2;
endpackage
module top;
  logic w;
endmodule
