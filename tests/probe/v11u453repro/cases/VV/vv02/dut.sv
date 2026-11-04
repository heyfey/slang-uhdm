// § pkgExplicitImpVarReExport453
package a;
  wire [3:0] na;
endpackage
package b;
  import a::na;
endpackage
module top;
  import b::*;
endmodule
