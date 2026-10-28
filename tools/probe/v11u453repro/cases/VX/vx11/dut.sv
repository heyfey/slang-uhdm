// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::PA;
  export a::PA;
endpackage
module top;
  import b::*;
  int x = PA;
endmodule
