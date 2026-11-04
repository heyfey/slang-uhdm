// § importEnumCloneHomeInst469
// an enum with an int base and explicit values, two importers
package a;
  typedef enum int {K0 = 5, K1 = 9} k_t;
  parameter k_t PK = K1;
  localparam k_t LK = K0;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
module top;
  logic w;
endmodule
