// § pkgExplicitImpVarReExport453
package a;
  int va;
endpackage
package b;
  import a::va;
  int vb;
endpackage
module top;
  import b::*;
endmodule
