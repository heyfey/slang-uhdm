// § importCopyTsInstByRole469
// a chain: c imports b and a, b imports a
package a;
  typedef logic [2:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
  import a::*;
endpackage
module top;
  logic w;
endmodule
