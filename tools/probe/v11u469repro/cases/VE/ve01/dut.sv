// § importEnumCloneHomeInst469
// a diamond: d imports b and c, both import the enum parameter's home a (per-path repeats)
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
package d;
  import b::*;
  import c::*;
endpackage
module top;
  logic w;
endmodule
