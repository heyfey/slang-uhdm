// § importCopyTsInstByRole469
// the home is declared after the importer is used by a module (source order)
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
  parameter t PB = PA + 1;
endpackage
package b;
  import a::*;
  parameter int PC = PB;
endpackage
module top;
  import b::*;
  int x = PC;
endmodule
