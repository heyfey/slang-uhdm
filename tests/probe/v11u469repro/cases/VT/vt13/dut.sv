// § importCopyTsInstByRole469
// a pure chain: c imports b only, b imports a (Surelog's transitive import)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd7;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
endpackage
module top;
  logic w;
endmodule
