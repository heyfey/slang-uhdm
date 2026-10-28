// § pkgImpParamsAheadOfOwn453
package a;
  parameter int PA = 1;
endpackage
package b;
  parameter int PB = 2;
  import a::*;
  parameter int PC = PA + PB;
endpackage
module top;
  import b::*;
  int x = PC;
endmodule
