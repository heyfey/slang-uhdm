// § importCopyTsInstByRole469
// a diamond: d imports b and c which both import a (per-path repeats)
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
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
