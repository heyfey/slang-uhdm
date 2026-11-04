// § pkgExplicitImpParamReExport453
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::*;
  import a::PA;
endpackage
module top;
  import b::*;
endmodule
