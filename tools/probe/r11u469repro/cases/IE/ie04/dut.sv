// § importEnumCloneHomeInst469
// an explicit import of an enum parameter
package a;
  typedef enum logic {OFF, ON} s_t;
  parameter s_t PS = ON;
endpackage
package b;
  import a::PS;
endpackage
module top;
  logic w;
endmodule
