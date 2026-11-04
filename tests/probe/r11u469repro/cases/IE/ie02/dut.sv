// § importEnumCloneHomeInst469
// an enum with a bit base and two parameters of the type
package a;
  typedef enum bit [2:0] {R0 = 3'd1, R1 = 3'd4} r_t;
  parameter r_t P0 = R0;
  parameter r_t P1 = R1;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
