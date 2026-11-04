// § importEnumCloneHomeInst469
// explicit imports of the enum type and of the parameter
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
package b;
  import a::e_t;
  import a::PE;
endpackage
module top;
  logic w;
endmodule
