// § importCopyTsInstByRole469
// a $unit import of the importing package
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
endpackage
import b::*;
module top;
  logic w;
endmodule
