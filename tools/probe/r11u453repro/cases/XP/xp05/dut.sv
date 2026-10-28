// § pkgExplicitImpParamReExport453
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::t;
  import a::PA;
endpackage
module top;
  import b::*;
endmodule
