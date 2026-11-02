// § importCopyTsInstByRole469
// CONTROL-ish: a re-typedef of another package's typedef in the home (alias target in z)
package z;
  typedef logic [3:0] t;
endpackage
package a;
  typedef z::t t2;
  parameter t2 PA = 3;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
