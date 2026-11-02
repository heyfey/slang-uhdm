// § importCopyTsInstByRole469
// an int typedef parameter
package a;
  typedef int t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
