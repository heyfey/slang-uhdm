// § pkgInitImpReadFolds471
// package parameter typed by an imported typedef and read in a class parameter of the package
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd5;
endpackage
package b;
  import a::*;
  parameter t PBB = PA;
  class C #(int N = PA);
    int v = N;
  endclass
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PBB;
endmodule
