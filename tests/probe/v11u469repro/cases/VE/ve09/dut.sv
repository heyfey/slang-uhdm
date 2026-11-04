// § importEnumCloneHomeInst469
// an enum typedef'd inside the importer from the home's enum, and the home parameter
package a;
  typedef enum logic {OFF, ON} s_t;
  parameter s_t PS = ON;
endpackage
package b;
  import a::*;
  typedef s_t s2_t;
  parameter s2_t PB = OFF;
endpackage
module top;
  logic w;
endmodule
