// § importCopyTsInstByRole469
// a typedef parameter in a package imported by a package that a class lives in
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
  class C;
    t m = PA;
  endclass
endpackage
module top;
  import b::*;
  C h;
endmodule
