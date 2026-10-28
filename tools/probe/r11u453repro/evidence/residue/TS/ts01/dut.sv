// residue: a typedef-typed package parameter re-exported through a second package
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
module top;
  import a::*;
endmodule
