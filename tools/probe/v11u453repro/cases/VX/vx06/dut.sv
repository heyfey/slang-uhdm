// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::PA;
  parameter int PB = PA + 1;
endpackage
module top;
  import b::*;
  int x = PB;
endmodule
