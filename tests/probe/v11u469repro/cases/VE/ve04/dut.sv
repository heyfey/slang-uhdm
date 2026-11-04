// § importEnumCloneHomeInst469
// a module reads the enum parameter through the importing package (downstream)
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E2;
endpackage
package b;
  import a::*;
  import a::PE;
  export a::PE;
endpackage
module top(output logic [1:0] y);
  import b::*;
  assign y = PE;
endmodule
