// § importEnumCloneHomeInst469
// an anonymous-enum typed parameter (no typedef)
package a;
  parameter enum {X0, X1} PX = X1;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
