// § importCopyTsInstByRole469
// a typedef-typed package parameter wildcard-imported by a second package (r11u453 TS/ts02)
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
endpackage
module top;
  import b::*;
endmodule
